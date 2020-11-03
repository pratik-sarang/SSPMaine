/*
* classname     :  SSP_AgentAssistorController
* @description  :  Controller Class for Agent and Assister. 
The class is running in without sharing mode, since it will fetch 
a list of contacts which the logged in citizen user will not be the owner of, 
in order to relate the contacts to the application through the ACR record.
* @author       :  Yathansh Sharma  
* @date         :  01/27/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/
public without sharing class SSP_AgentAssistorController {
    public static List<LOG_LogMessage__c> lstLogs = new List<LOG_LogMessage__c>();
    /***************************************************************************************************
* @author       Yathansh Sharma
* @date         1/27/2019
* @methodname   getAgentAndAssisstor
* @description  This method takes a returns a list of agent/assister based on the input parameters.
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getAgentAndAssisstor(String contactType, queryComponents queryData){
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_AgentAssistorController.contactOrganization> lstContactOrganization =  new List<SSP_AgentAssistorController.contactOrganization>();
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        List<User> lstUser = new List<User>();
        Set<String> setContactId = new Set<String>();
        Boolean hasAgencyWithSearchedZipcode = false;
        response.put('LanguageTypes',SSP_Utility.getPickListValues('Contact', 'PreferredLanguageCode__c', null));
        response.put('HoursTypes',SSP_Utility.getPickListValues('Contact', 'HoursAvailableCode__c', null));
        String acrRole = '';
        try{
            if(contactType == 'Agent'){
                acrRole = 'Insurance_Agent';
            }else{
                acrRole='Assister'; 
            }
            
            if((queryData.latitude == null || queryData.latitude == '') && UserInfo.getUserType() != 'Guest'){
                queryData.memberId = SSP_Utility.getCurrentUserMemberId(false);
                response.put('memberId', queryData.memberId);
                ssp_member__c member =  new ssp_member__c();
                if(queryData.memberId != null){
                    member = SSP_MemberSelector.queryMemberDataById(queryData.memberId, new String[]{'PhysicalGeolocation__latitude__s', 'PhysicalGeolocation__longitude__s'});
                    
                }if(member != null && member.PhysicalGeolocation__latitude__s != null){
                    queryData.latitude = String.valueOf(member.PhysicalGeolocation__latitude__s);
                }
                if(member != null && member.PhysicalGeolocation__longitude__s != null){
                    queryData.longitude = String.valueOf(member.PhysicalGeolocation__longitude__s);
                }
            }
            
            /**  if(queryData.latitude == null || queryData.longitude == null){
response.put('error','Cannot fetch geolocation.');
response.put('contactRecords', new list<contact>());

return response;
}**/
            
            Map<String, String> detailMap = new Map<string,String>();
            Map<String, String> conditionMap = new Map<String, String>();
            
            detailMap.put('objectName','contact');
            detailMap.put('operator','AND');
            
            // conditionMap.put('RecordType.DeveloperName', 'Non_Citizen');
            if(queryData.FirstName != null && queryData.FirstName != ''){
                detailMap.put('FirstName', 'like');
                conditionMap.put('FirstName', '%'+queryData.FirstName+'%');
            }
            
            if(queryData.LastName != null && queryData.LastName != ''){
                detailMap.put('LastName', 'like');
                conditionMap.put('LastName', '%'+queryData.LastName+'%');
            }
            /* acrList = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
new Set<String>{'Id','account.Name','contactId','account.DCdataId__c','Roles','dcAgencyId__c','dcContactId__c'}, 
new Map<String, String>{'limit'=>'1000','account.recordtype.name'=>'Organization','Roles'=>acrRole});*/
            acrList = SSP_SharingBypassFetcher.fetchAssisterList(acrRole);
            for(AccountContactRelation objACR: acrList){
                
                setContactId.add(objACR.contactId);
                
            }
            if(!setContactId.isEmpty()){
                detailMap.put('IN', 'Id');
                conditionMap.put('Id', String.join(new List<String>(setContactId),','));
            }
            conditionMap.put('limit', '10000');
            if(acrRole == 'Insurance_Agent') {
                Date today = SSP_Utility.today();
                conditionMap.put('ActiveHealthLicenseFlag__c', 'Y');
                conditionMap.put('IndividualCertificationEndDate__c', String.valueOf(today.year()));
                detailMap.put('IndividualCertificationEndDate__c', '>=');
            }
            String acrQueryForAgenciesDetermination ='(select id,account.recordtype.name,account.name,account.dcdataId__c,account.BillingPostalCode,account.phone from accountcontactRelations where account.recordtype.name ='+'\''+ 'Organization' + '\''+')';
            
            list<contact> contactData = new list<contact>();
            list<contact> lstAsscoiatedAgencies= new list<contact>();
            
            if(queryData.ZipCode != null && queryData.ZipCode != ''){
                lstAsscoiatedAgencies = SSP_ContactSelector.queryContactData(detailMap, new Set<String>{'id','name',acrQueryForAgenciesDetermination,'AssociatedCountyCode__c', 'MailingCountry', 'MailingPostalCode', 'AccountId', 'Account.BillingPostalCode','PreferredLanguageCode__c','SpokenLanguageCode__c', 'HoursAvailableCode__c', 'IsSearchEnabled__c', 'InHousePrivateAssister__c','Account.Name'}, 
                                                                             conditionMap);
                
                for(contact objcontact: lstAsscoiatedAgencies){
                    if(!objcontact.accountcontactRelations.isEmpty()){
                        for(AccountContactRelation objACR:objcontact.accountcontactRelations){                 
                            if(!hasAgencyWithSearchedZipcode){
                                hasAgencyWithSearchedZipcode = (queryData.ZipCode != null && objACR.account.BillingPostalCode != null && queryData.ZipCode == objACR.account.BillingPostalCode)?true:false;
                            }}                    
                    }
                }     
            }
            String Organization ='Organization';
            String acrQuery ='(select id,account.recordtype.name,account.name,dcagencyId__c,dccontactId__c,account.dcdataId__c,account.BillingPostalCode,account.phone,Roles,account.BillingStreet,account.BillingCity,account.BillingState,account.Email__c from accountcontactRelations where account.recordtype.name ='+'\''+ String.escapeSingleQuotes(Organization) + '\''+')';
            
            if(queryData.Organization != null && queryData.Organization != '' && (contactType == 'Assister'  || (contactType != 'Assister' && (queryData.ZipCode == null || queryData.ZipCode == '')))){
                acrQuery ='(select id,account.recordtype.name,account.name,dcagencyId__c,dccontactId__c,account.dcdataId__c,account.BillingPostalCode,account.phone,Roles,account.BillingStreet,account.BillingCity,account.BillingState,account.Email__c from accountcontactRelations where account.recordtype.name ='+'\''+ String.escapeSingleQuotes(Organization) + '\''+
                    ' and account.name like '+'\''+ '%'+String.escapeSingleQuotes(queryData.Organization) +'%'+ '\''+  ')';          
            }
            if(queryData.Organization != null && queryData.Organization != ''  && contactType != 'Assister' && queryData.ZipCode!= null && queryData.ZipCode != '' && hasAgencyWithSearchedZipcode){
                acrQuery ='(select id,account.recordtype.name,account.name,dcagencyId__c,dccontactId__c,account.dcdataId__c,account.BillingPostalCode,account.phone,Roles,account.BillingStreet,account.BillingCity,account.BillingState,account.Email__c from accountcontactRelations where account.recordtype.name ='+'\''+ String.escapeSingleQuotes(Organization) + '\''+
                    ' and account.name like '+'\''+ '%'+String.escapeSingleQuotes(queryData.Organization) +'%'+ '\''+  ' and account.BillingPostalCode ='+'\''+ String.escapeSingleQuotes(queryData.ZipCode) + '\''+ ')';            
            }else if(queryData.Organization != null && String.escapeSingleQuotes(queryData.Organization) != ''  && contactType != 'Assister' && queryData.ZipCode!= null && queryData.ZipCode != ''){
                acrQuery ='(select id,account.recordtype.name,account.name,dcagencyId__c,dccontactId__c,account.dcdataId__c,account.BillingPostalCode,account.phone,Roles,account.BillingStreet,account.BillingCity,account.BillingState,account.Email__c from accountcontactRelations where account.recordtype.name ='+'\''+String.escapeSingleQuotes(Organization) + '\''+
                    ' and account.name like '+'\''+ '%'+String.escapeSingleQuotes(queryData.Organization) +'%'+ '\''+  ')';  
            }
            if((queryData.Organization == null || queryData.Organization == '')  && contactType != 'Assister' && queryData.ZipCode!= null && queryData.ZipCode != '' && hasAgencyWithSearchedZipcode){
                acrQuery ='(select id,account.recordtype.name,account.name,dcagencyId__c,dccontactId__c,account.dcdataId__c,account.BillingPostalCode,account.phone,Roles,account.BillingStreet,account.BillingCity,account.BillingState,account.Email__c from accountcontactRelations where account.recordtype.name ='+'\''+ String.escapeSingleQuotes(Organization) + '\''+
                    ' and account.BillingPostalCode ='+'\''+ String.escapeSingleQuotes(queryData.ZipCode) + '\''+ ')';          
            }
            acrQuery = acrQuery.replace(')', ' and Roles includes (\''+String.escapeSingleQuotes(acrRole)+'\'))');
            response.put('acrQuery', acrQuery);
            
            System.debug('### acrQuery ###'+acrQuery);
            conditionMap.put('limit', '10000');
            if(queryData.latitude != null && queryData.latitude != ''){
                contactData = SSP_AgentAssistorController.filterZipCodeOnContacts(SSP_ContactSelector.queryContactData(detailMap, new Set<String>{'id','FirstName','LastName','name','phone',acrQuery,'AssociatedCountyCode__c', 'MailingCountry', 'MailingPostalCode', 'AccountId', 'Account.BillingPostalCode','PreferredLanguageCode__c','SpokenLanguageCode__c', 'HoursAvailableCode__c', 'IsSearchEnabled__c', 'InHousePrivateAssister__c','Account.Name','distance(mailingLatitude, Geolocation('+queryData.latitude+','+queryData.longitude+'), \'mi\') distance'}, 
                                                                                                                       conditionMap), contactType, queryData);
            }else{
                contactData = SSP_AgentAssistorController.filterZipCodeOnContacts(SSP_ContactSelector.queryContactData(detailMap, new Set<String>{'id','FirstName','LastName','name','phone',acrQuery,'AssociatedCountyCode__c', 'MailingCountry','MailingPostalCode', 'AccountId', 'Account.BillingPostalCode','PreferredLanguageCode__c','SpokenLanguageCode__c', 'HoursAvailableCode__c', 'IsSearchEnabled__c', 'InHousePrivateAssister__c','Account.Name'}, 
                                                                                                                       conditionMap), contactType, queryData);
            }
            
            List<String> lstOrganizations =  new  List<String>();
            for(contact objContact : contactData){
                if((!objContact.accountcontactRelations.isEmpty()) && objContact.accountcontactRelations[0].Roles != null && objContact.accountcontactRelations[0].Roles.Contains(acrRole)){
                    SSP_AgentAssistorController.contactOrganization objOrganization=  new SSP_AgentAssistorController.contactOrganization();
                    
                    SSP_AgentAssistorController.contactOrganization objContactOrganization=  new SSP_AgentAssistorController.contactOrganization();
                    objContactOrganization.objContact = objContact;
                    objContactOrganization.FirstName = objContact.FirstName;
                    objContactOrganization.LastName = objContact.LastName != null ?objContact.LastName: '';
                    objContactOrganization.organizationName=objContact.accountcontactRelations[0].account.name;
                    objContactOrganization.isOrganization = false;
                    
                    if(objContact.phone != null){
                          objContactOrganization.organizationPhone=objContact.phone;
                    }
                    else if(objContact.accountcontactRelations[0].account.phone != null){
                        objContactOrganization.organizationPhone=objContact.accountcontactRelations[0].account.phone;
                    }
                    if(objContact.accountcontactRelations[0].account.dcDataId__c != null){
                        objContactOrganization.organizationDataId = String.valueOf(objContact.accountcontactRelations[0].account.dcDataId__c);
                    }else{
                        objContactOrganization.organizationDataId = '';  
                    } 
                    if(objContact.accountcontactRelations[0].dccontactId__c  != null){
                        objContactOrganization.organizationContactId = String.valueOf(objContact.accountcontactRelations[0].dccontactId__c );
                    }else{
                        objContactOrganization.organizationContactId = '';  
                    } 
                    if((!lstOrganizations.contains(objContact.accountcontactRelations[0].account.name)) && contactType == 'Assister'){
                        
                        objOrganization.objContact = objContact;
                        lstOrganizations.add(objContact.accountcontactRelations[0].account.name);
                        objOrganization.FirstName =objContact.accountcontactRelations[0].account.name;
                        objOrganization.LastName =  '';
                        
                        objOrganization.organizationName='';
                        if(objContact.accountcontactRelations[0].account.phone != null){
                            objOrganization.organizationPhone=objContact.accountcontactRelations[0].account.phone;
                        }
                        objOrganization.organizationEmail =  objContact.accountcontactRelations[0].account.Email__c != null ? objContact.accountcontactRelations[0].account.Email__c:'';  
                        objOrganization.organizationAddressLine1 = objContact.accountcontactRelations[0].account.BillingStreet != null?objContact.accountcontactRelations[0].account.BillingStreet:''+' '+
                            objContact.accountcontactRelations[0].account.BillingCity != null?objContact.accountcontactRelations[0].account.BillingCity:'';
                        objOrganization.organizationAddressLine2 = objContact.accountcontactRelations[0].account.BillingState != null?objContact.accountcontactRelations[0].account.BillingState:''+', '+
                            objContact.accountcontactRelations[0].account.BillingPostalCode != null?objContact.accountcontactRelations[0].account.BillingPostalCode:'';
                        if(objContact.accountcontactRelations[0].account.dcDataId__c != null){
                            objOrganization.organizationDataId = String.valueOf(objContact.accountcontactRelations[0].account.dcDataId__c);
                        }else{
                            objOrganization.organizationDataId = '';  
                        } 
                        if(objContact.accountcontactRelations[0].dccontactId__c  != null){
                            objOrganization.organizationContactId = String.valueOf(objContact.accountcontactRelations[0].dccontactId__c );
                        }else{
                            objOrganization.organizationContactId = '';  
                        } 
                        objOrganization.isOrganization = true;
                    }
                    if(objOrganization != null&& objOrganization.organizationName != null){
                        lstContactOrganization.add(objOrganization);       
                    }
                    lstContactOrganization.add(objContactOrganization);
                    
                } 
                
                
            }
            response.put('conditions', conditionMap);
            response.put('contactRecords', lstContactOrganization);
        }catch(exception e){
            response.put('contactRecords', new list<contact>());
            
        }
        
        return response;
    }
    
    
    /***************************************************************************************************
* @author       Yathansh Sharma
* @date         1/27/2019
* @methodname   filterZipCodeOnContacts
* @description  Filters the lsit of recieved contacts based on their zip code.
* @return       ssp_LightningResponse
*****************************************************************************************************/
    public static list<Contact> filterZipCodeOnContacts(List<Contact> recordList, String contactType,queryComponents queryData){
        List<Contact> filteredList = new List<Contact>();
        string strCountList ='';
        String zipCode;
        
        if(queryData.ZipCode != null && queryData.ZipCode != ''){
            zipCode = queryData.ZipCode;
        }
        if(zipCode == null || zipCode == ''){
            return recordList;
        }
        if(contactType == 'Assister'){
            List<SSP_CountyZipCodeAssociation__c> lstCountyMetadata = new List<SSP_CountyZipCodeAssociation__c>();
            lstCountyMetadata = SSP_SharingBypassFetcher.fetchCountyZipCode(zipCode);
            for(SSP_CountyZipCodeAssociation__c objCountCode: lstCountyMetadata){
                if(strCountList == ''){
                    strCountList = objCountCode.CountyCode__c;
                }else{
                    strCountList = strCountList + ','+objCountCode.CountyCode__c;
                }
            }
            if(strCountList != ''){
                String countyList =strCountList.replaceAll(' ','').replaceAll(',', '|');
                Pattern countyPattern = Pattern.compile(countyList);
                for(Contact con: recordList){
                    String mailingCountyList = (con.AssociatedCountyCode__c != null)?con.AssociatedCountyCode__c:'';
                    Matcher countyMatcher = countyPattern.matcher(mailingCountyList);
                    if(countyMatcher.find()){
                        filteredList.add(con);
                    }
                }
            }
        }else{
            for(Contact con: recordList){               
                if(zipCode == null || ((con.MailingPostalCode != null && con.MailingPostalCode == zipCode) 
                                       || ((!con.accountcontactRelations.isEmpty()) && con.accountcontactRelations[0].account.BillingPostalCode != null &&
                                           con.accountcontactRelations[0].account.BillingPostalCode == zipCode))){
                                               filteredList.add(con);
                                           }
            }
        }
        return filteredList;
    }
    
    /***************************************************************************************************
* @author       Yathansh Sharma
* @date         1/27/2019
* @methodname   fetchContactInformation
* @description  Gets the information for a single contact.
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @auraEnabled(cacheable=true) 
    public static SSP_LightningResponse fetchContactInformation(Id sspContactId, String callingComponent, String sRoleType ){
        //SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        Set<String> fieldSet = new Set<String>{'Id','FirstName','MiddleName','LastName','SpokenLanguageCode__c', 'PreferredLanguageCode__c','Email','InHousePrivateAssister__c','Phone','AgencyOrOrganization__c','AgencyOrOrganization__r.name','HoursAvailableCode__c','IsSearchEnabled__c','OrganizationName__c','toLabel(CountyCode__c)','Zipcode5__c','Zipcode4__c','AddressLine2__c','Street__c','City__c','SSP_State__c', 'MailingStreet', 'MailingCity', 'MailingPostalCode', 'MailingState'};
            List<Contact> contactList = new List<Contact>();
         List<AccountContactRelation> contactRoleList = new List<AccountContactRelation>();
        try{
            if(sspContactId != null){                
               
        		contactRoleList = [SELECT Id from AccountContactRelation WHERE account.recordtype.developerName = 'Resource_Engine' AND (Roles INCLUDES ('Assister') OR Roles INCLUDES ('Agency_Admin') OR Roles INCLUDES ('Insurance_Agent')) AND contactId=:sspContactId AND contact.recordtype.developername = 'Non_Citizen'];
                if(contactRoleList.isEmpty()){
                    return response;
                }
                Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1','Id'=> sspContactId};                    
                    contactList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                       fieldSet, 
                                                                       conditionMap);                    
                
                response.put('contactRecord',(contactList != null && !contactList.isEmpty()) ? contactList[0] : null);
            }
            response.put('LanguageTypes',SSP_Utility.getPickListValues('Contact', 'PreferredLanguageCode__c', null));
            response.put('HoursTypes',SSP_Utility.getPickListValues('Contact', 'HoursAvailableCode__c', null));
            response.bIsSuccess = true;
        }catch(Exception ex){
            response.put('ERROR',ex.getStackTraceString());
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AddAuthRepController', 'fetchContactInformation', ex.getMessage() , true);
        }
        
        
        return response;
    }
    
    /***************************************************************************************************
* @author       Yathansh Sharma
* @date         1/27/2019
* @methodname   upsertAgentAssister
* @description  Creates a new ACR between agent/assister and application account.
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse upsertAgentAssister(Id applicationId, Id contactId, String roleType,String accountDataId,String accountContactId,Boolean isOrganization){
        SSP_Utility.isAuthenticatedUser();
        roleType = (roleType == 'Agent')? SSP_GlobalConstants.INSURANCEAGENT_ROLE: roleType;
        
        SSP_Application__c application = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                      new Set<String>{'id', 'Account__c','DCCaseNumber__c','ProgramsApplied__c','Name'}, 
                                                                                      new Map<String, String>{'id'=>applicationId})[0];
        SSP_LightningResponse response = new SSP_LightningResponse();
        ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT);
        List<AccountContactRelation> acRecords=new List<AccountContactRelation>();
        List<AccountContactRelation> acRecordsForRoleCheck=new List<AccountContactRelation>();
        List<AccountContactRelation> lstAssisterACR =  new List<AccountContactRelation>();
        contact contactForInterface;
        Boolean isCalloutCompleted =false;
        String isUpdateAgencySuccess = '';
        String hbeResponse = '';
        String citizenCounty = '';
        Boolean hasExistingAssociation = false;
        String memberAccount;
        try{
             if(applicationId != null ){
            SSP_LightningResponse objResponse = new SSP_LightningResponse();           
            objResponse = SSP_AuthRepAccessRequestService.getRequestAccessPermission(applicationId);
            if(objResponse != null && objResponse.mapResponse != null && (!objResponse.mapResponse.containsKey('hasAccess'))){
            response.put('hasNoAccess',true);
            response.bIsSuccess = true;
            return response;    
            }
            }
            if(isOrganization == null){
               isOrganization = false; 
            }
          
            if( isOrganization && application != null && application.Id != null ){
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData( application.Id,new set<string>{'SSP_Member__r.Contact__r.AccountId'});
            memberAccount = applicationIndividuals != null && !applicationIndividuals.isEmpty() ? applicationIndividuals[0].SSP_Member__r.Contact__r.AccountId : null; 
            if(applicationIndividuals != null && (!applicationIndividuals.isEmpty()) && applicationIndividuals[0].SSP_Member__c != null &&  applicationIndividuals[0].SSP_Member__r.PhysicalCountyCode__c != null){
                citizenCounty =  applicationIndividuals[0].SSP_Member__r.PhysicalCountyCode__c;
               
            }
                if(citizenCounty != null && citizenCounty != '' && accountDataId != null && accountDataId != ''){
                      lstAssisterACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','contact.AssociatedCountyCode__c','contactId'}, 
                                                            new Map<String, String>{'Account.DCDataId__c'=> accountDataId});
                    for(AccountContactRelation objACR:lstAssisterACR){
                        if(objACR.contact != null && objACR.contact.AssociatedCountyCode__c != null && objACR.DCContactId__c != null && objACR.contact.AssociatedCountyCode__c.contains(citizenCounty)){
                            contactId = objACR.contactId;
                            accountContactId = String.valueOf(objACR.DCContactId__c);
                            break;
                        }
                    }
                }
        }
        else if(String.isNotBlank(applicationId)){
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData( application.Id,new set<string>{'SSP_Member__r.Contact__r.AccountId'}); //#
            memberAccount = applicationIndividuals != null && !applicationIndividuals.isEmpty() ? applicationIndividuals[0].SSP_Member__r.Contact__r.AccountId : null; //#
        }
            acRecordsForRoleCheck = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                                    new Set<String>{'id','accountId', 'contactId','contact.AgencyOrOrganization__r.DCDataId__c','contact.IndividualId__c','contact.DCDataId__c','contact.Phone','DCAgencyId__c','Roles'}, 
                                                                                    new Map<String, String>{'accountId'=>application.account__c});
            contactForInterface = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                                       new Set<String>{'id','AgencyOrOrganization__r.DCDataId__c','IndividualId__c','DCDataId__c','Phone'}, 
                                                                       new Map<String, String>{'Id'=>contactId})[0];
            
            if((!acRecordsForRoleCheck.isEmpty()) && acRecordsForRoleCheck[0].contactId == contactId &&acRecordsForRoleCheck[0].Roles != null && acRecordsForRoleCheck[0].Roles != roleType){
                response.put('ERROR', 'User is already assocaited with the case.');     
                return response;
            }
            if((!acRecordsForRoleCheck.isEmpty()) && acRecordsForRoleCheck[0].contactId == contactId && acRecordsForRoleCheck[0].Roles != null &&  acRecordsForRoleCheck[0].Roles == roleType && ((accountDataId == null || accountDataId == '') || 
                                                                                                                                                                                                  (accountDataId != null && accountDataId != '' && acRecordsForRoleCheck[0].DCAgencyId__c != null && String.valueOf(acRecordsForRoleCheck[0].DCAgencyId__c) == accountDataId))){
                                                                                                                                                                                                      
                                                                                                                                                                                                      response.put('success', true);
                                                                                                                                                                                                      response.put('noChange', true);
                                                                                                                                                                                                      return response;
                                                                                                                                                                                                  }
            
            for(AccountContactRelation objACR: acRecordsForRoleCheck){
                if(objACR.Roles != null && objACR.Roles == roleType){
                    acRecords.add(objACR);
                }
            }
            
            isUpdateAgencySuccess = (application.DCCaseNumber__c != null)? triggerUpdateAgentAssisterService(application,contactForInterface,roleType,false,accountDataId,accountContactId):'true';
            
            if(isUpdateAgencySuccess == 'true'){              
                
                hbeResponse = (roleType != SSP_GlobalConstants.INSURANCEAGENT_ROLE) ?triggerHBE016(application,accountContactId,accountDataId,'HBE-016') :'';
               
            }else{
                if(accountDataId == null || accountDataId == ''){
                    isUpdateAgencySuccess = 'Invalid Data';
                }
                response.put('ERROR', isUpdateAgencySuccess);
                response.put('SERVICE_ERROR', isUpdateAgencySuccess); 
                if(!lstLogs.isEmpty()){
                    ESAPI.accessController().insertAsUser(new List<LOG_LogMessage__c>{lstLogs[0]}, SSP_Utility.getFieldsNamesObject(lstLogs[0]));//new List<String>{'accountId', 'contactId', 'roles'}
                    
                }
                return response;
            }
            if((roleType != SSP_GlobalConstants.INSURANCEAGENT_ROLE && isUpdateAgencySuccess == 'true' && hbeResponse == 'true') || (roleType == SSP_GlobalConstants.INSURANCEAGENT_ROLE && isUpdateAgencySuccess == 'true')){
                isCalloutCompleted =true;             
                if((!acRecords.isEmpty()) && acRecords[0].contactId == contactId && acRecords[0].Roles != null && acRecords[0].Roles == roleType && ((accountDataId == null || accountDataId == '') || 
                                                                                                                                                     (accountDataId != null && accountDataId != '' && acRecords[0].DCAgencyId__c != null && String.valueOf(acRecords[0].DCAgencyId__c) == accountDataId))){
                                                                                                                                                         response.put('success', true);
                                                                                                                                                         response.put('noChange', true);
                                                                                                                                                         return response;
                                                                                                                                                     }else if((!acRecords.isEmpty()) && acRecords[0].Roles != null && acRecords[0].Roles == roleType){
                                                                                                                                                         ESAPI.accessController().deleteAsUser(acRecords);
                                                                                                                                                         acRecords.clear();
                                                                                                                                                     }
            }else {
                
                response.put('ERROR', hbeResponse);
                response.put('SERVICE_ERROR', hbeResponse);
            }
        }catch(exception e){
            //  
            // 
        }finally{
            if(accountDataId != null && accountDataId != '' && accountContactId != null && accountContactId != ''){
                acRecords.add(new AccountContactRelation(AccountId = application.account__c, ContactId = contactId, roles = roleType,DCAgencyId__c = Integer.valueOf(accountDataId),dcContactId__c=Integer.ValueOf(accountContactId)));
            }else if(accountDataId != null && accountDataId != ''){
                acRecords.add(new AccountContactRelation(AccountId = application.account__c, ContactId = contactId, roles = roleType,DCAgencyId__c = Integer.valueOf(accountDataId)));
            }else{
                acRecords.add(new AccountContactRelation(AccountId = application.account__c, ContactId = contactId, roles = roleType));
                
            }
        }
        
        try{
            if(isCalloutCompleted){
                constructMemberACR(memberAccount, contactId);
                ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acRecords[0]}, SSP_Utility.getFieldsNamesObject(acRecords[0]));//new List<String>{'accountId', 'contactId', 'roles'}
                List<User> userList = new   List<User>();
                
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                String individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
                
                if(individualId != null && individualId != ''){  
                    
                    userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                              new Set<String>{'Id', 'ContactId','contact.FirstName','contact.LastName','profile.name','contact.IndividualId__c','contact.Email','contact.GenderCode__c','contact.BirthDate'}, 
                                                              new Map<String, String>{'limit'=>'1','contact.IndividualId__c'=> individualId});
                    
                    
                }
                 if(!lstLogs.isEmpty()){
                    ESAPI.accessController().insertAsUser(lstLogs, SSP_Utility.getFieldsNamesObject(lstLogs[0]));//new List<String>{'accountId', 'contactId', 'roles'}
                    
                }
                if(!userList.isEmpty()){
                    SSP_ProgramSelectionService.resetDashboardRefreshFlag(userList[0].contactId); 
                }
                response.put('success', true);
            }
        }catch(exception e){
            response.put('success', false);
            response.put('error', e.getMessage());
            
            
        }
        
        return response;
    }

    private static AccountContactRelation constructMemberACR(String accountId, String contactId){
        List<AccountContactRelation> acrList = new List<AccountContactRelation>();
        try{
            if(String.isNotBlank(accountId) && String.isNotBlank(contactId)){
                User loggedInUser = SSP_Utility.getCurrentUserDetails()[0];    
                Set<String> existingAccountSet = new Set<String>();
                AccountContactRelation acr = new AccountContactRelation();
                acr.ContactId = contactId;
                acr.AccountId = accountId;
                acrList.add(acr);
                insert acrList;
            }
                
        }
        
        catch(Exception ex){
            return null;
        }
        
        return !acrList.isEmpty() ? acrList[0] : null;
    }

    public static final String SSP_AGENT = 'Agent';
    public static final String SSP_ASSISTER = 'Assister';
    
    
    public static String triggerUpdateAgentAssisterService(SSP_Application__c application,contact objRelation,String RoleType,Boolean isDelete,String accountDataId,String accountContactId){
        String result = '';
        String ErrorId = ''; 
        String agentRole =SSP_GlobalConstants.INSURANCEAGENT_ROLE;
        IF(RoleType == SSP_GlobalConstants.INSURANCE_AGENT_ROLE){
            RoleType=SSP_GlobalConstants.INSURANCEAGENT_ROLE;
        }
        SSP_UpdateAgentAssisterRequestWrapper objRequest = new  SSP_UpdateAgentAssisterRequestWrapper();
        SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel objChild = new SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel();
        List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel> lstChild = new List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel>();
        List<Contact> userList = new   List<Contact>();
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        //if(objRelation.contact.AgencyOrOrganization__c != null && objRelation.contact.AgencyOrOrganization__r.DCdataId__c != null){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        String individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
        
        if(individualId != ''){  
            
            /* userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
new Set<String>{'Id', 'ContactId','contact.FirstName','contact.LastName','profile.name','contact.IndividualId__c','contact.Email','contact.GenderCode__c','contact.BirthDate','contact.phone'}, 
new Map<String, String>{'limit'=>'1','contact.IndividualId__c'=> individualId});*/
            userList = SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'contact','operator'=>'AND'}, 
                                                            new Set<String>{'id','FirstName','LastName','IndividualId__c','Email','GenderCode__c','BirthDate','phone'}, 
                                                            new Map<String, String>{'IndividualId__c'=>individualId});
            
        }
        
        String sessionData =  sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId'));
        if(sessionData!=null && sessionData!=''){
            mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize(sessionData, Map<String, String>.class);  
        }
        if(!userList.isEMpty()){       
            objRequest.Operation = 'update';
            objChild.AgencyId =(RoleType != agentRole && accountDataId != null && accountDataId != ''  && (!isDelete)) ?
                accountDataId: null;
            objChild.CaseNumber = application.DCCaseNumber__c != null ? String.valueOf(application.DCCaseNumber__c):null;
            objChild.IndividualId =  mapCaseVsIndividualId.get(String.valueOf(application.DCCaseNumber__c)) != null ? mapCaseVsIndividualId.get(String.valueOf(application.DCCaseNumber__c)):null;
            objChild.AgencyEmployeeId = (RoleType != agentRole && accountContactId != null && accountContactId != '' && (!isDelete)) ? accountContactId:null;
            objChild.IndividualContactPhone = userList[0].Phone != null ?  userList[0].Phone:null;
            objChild.DoiAgentId = (RoleType == agentRole && accountContactId != null && accountContactId != '' && (!isDelete)) ? accountContactId:null;
            objChild.DoiAgencyId =(RoleType == agentRole && accountDataId != null && accountDataId != '' && (!isDelete)) ?
                accountDataId: null;
            objchild.IsAssisterUpdate =(RoleType != agentRole)?'true':'false'; 
            objchild.IsAgentUpdate =(RoleType == agentRole)?'true':'false';
            lstChild.add(objchild);
            objRequest.DCAgencyIndividualCaseAssociationModel =lstChild ;
            Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objRequest) };
                objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,application.Id);//put the app id for which you are invoking this service
            objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,application.DCCaseNumber__c);//put the CaseNumber for which you are invoking this service
            List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPUpdateAgentAssister_METADATANAME , objResponse);
            if(lstData != null && (!lstData.isEmpty())){
                SSP_UpdateAgentAssisterResWrapper objResult = (SSP_UpdateAgentAssisterResWrapper)lstData[0];
                
                if(objResult != null && ((objResult.isSFFailure != null && (!objResult.isSFFailure)) || (objResult.isSFFailure == null)) && objResult.AckResponse != null && objResult.AckResponse.success != null && objResult.AckResponse.success){
                    result = 'true';
                }else if (objResult != null && ((objResult.isSFFailure != null && (objResult.isSFFailure)) || (objResult.isSFFailure == null)) || (objResult.AckResponse != null  && objResult.AckResponse != null && objResult.AckResponse.Error != null)){
                    if(objResult.AckResponse.Error.CHFSExceptionId != null){
                        result = objResult.AckResponse.Error.CHFSExceptionId;
                    }else if(objResult.AckResponse.Error.ErrorCode != null){
                        result = objResult.AckResponse.Error.ErrorCode;
                    }
                    
                }
                if(lstData.size() >1 && lstData[1] != null){                   
                    LOG_LogMessage__c objLog = (LOG_LogMessage__c) lstData[1];
                    lstLogs.add(objLog);
                    if(isDelete){
                        ESAPI.accessController().insertAsUser(new List<LOG_LogMessage__c>{lstLogs[0]}, SSP_Utility.getFieldsNamesObject(lstLogs[0]));//new List<String>{'accountId', 'contactId', 'roles'}
                    }
                }
            }
            
            
        }
        
        return result;
    }
    public static String triggerHBE016(SSP_Application__c application, String accountContactId, String accountDataId,String correspondenceType){
        String response = 'true';
        User objUser =  new User();        
        SSP_ApplicationIndividual__c objAppIndividual = new SSP_ApplicationIndividual__c();
        List<User> lstUser = new List<User>();
        List<Contact> lstContact = new List<Contact>();
        String IndividualIdForRequest;
        String sspMemberId;
        String individualId;
        Map<String, String> mapCaseVsIndividualId = new Map<String, String>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        individualId = sessionpart.get('individualId') != null ? String.valueOf(sessionpart.get('individualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,'individualId'));
        String sessionData =  sessionpart.get('caseVsIndividualId') != null ? String.valueOf(sessionpart.get('caseVsIndividualId')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsIndividualId'));
        if(sessionData!=null && sessionData!=''){
            mapCaseVsIndividualId = (Map<String, String>) JSON.deserialize(sessionData, Map<String, String>.class);  
        }
        
        if( application != null && application.Id != null ){
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData( application.Id,new set<string>{});
            if(applicationIndividuals != null && (!applicationIndividuals.isEmpty()) && applicationIndividuals[0].SSP_Member__c != null &&  applicationIndividuals[0].SSP_Member__r.IndividualId__c != null){
                individualId =  applicationIndividuals[0].SSP_Member__r.IndividualId__c;
                objAppIndividual = applicationIndividuals[0];
            }
        }
        if(individualId == null || individualId == ''){        
            objUser = (User)[SELECT Id, ImpersonatedIndividualId__c, SelectedRole__c,profile.name,contact.IndividualId__c, contact.MemberType__c  FROM User WHERE id = :UserInfo.getUserId()];
            if( objUser != null){
                individualId = objUser.ImpersonatedIndividualId__c!= null ? objUser.ImpersonatedIndividualId__c:(objUser.contact.IndividualId__c !=null && (objUser.profile.name.equalsIgnoreCase(SSP_GlobalConstants.RE_CITIZEN_PROFILE) || (objUser.SelectedRole__c != null && objUser.SelectedRole__c.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE)))) ? objUser.contact.IndividualId__c : '';
            } 
            
        }
       
        if(objAppIndividual != null){  
            Map<String, String> miscellaneousParameterMapping= new Map<String, String>{
                'IndividualFirstName'=> (objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.FirstName__c != null)? objAppIndividual.SSP_Member__r.FirstName__c :'',//'Logged in UserFirstName'
                    'IndividualMI'=>  (objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.MiddleInitial__c != null)? objAppIndividual.SSP_Member__r.MiddleInitial__c :'',
                        'IndividualLastName'=>  (objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.LastName__c != null)? objAppIndividual.SSP_Member__r.LastName__c :'',
                            'IndividualSuffix'=>(objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.SuffixCode__c != null)? objAppIndividual.SSP_Member__r.SuffixCode__c :'',
                                'Email'=>(objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.Email__c != null)? objAppIndividual.SSP_Member__r.Email__c :'',//'Logged in UserEmail'
                                    'PrimaryPhoneNumber'=>(objAppIndividual != null && objAppIndividual.SSP_Member__r != null && objAppIndividual.SSP_Member__r.PrimaryPhoneNumber__c != null)? objAppIndividual.SSP_Member__r.PrimaryPhoneNumber__c.replace('-','') :'',//'Logged in UserPrimaryPhoneNumber'                                     
                                    'AssocAgencyId'=>'',
                                        'AssocAgencyEmployeeId'=>'',
                                        'AssocDoiAgentId'=>'',
                                        'AssocDoiAgencyId'=>''
                                        };
                                            String param = '';
            for(String key : miscellaneousParameterMapping.keySet()){
                String value = miscellaneousParameterMapping.get(key);//get value corresponding to key being iterated
                param += key + ':' + value + '|';
            }
            param.removeEnd('|');
            SSP_CorrespondenceRequestWrapper hr = new SSP_CorrespondenceRequestWrapper(correspondenceType);
            
            if(accountContactId!=null){
                hr.AgencyEmployeeId = Integer.valueOf(accountContactId);
            }
            else{
                hr.AgencyEmployeeId = 0;
            }
            if(accountDataId != null){
                hr.AgencyId = Integer.valueOf(accountDataId);
            }else {
                hr.AgencyId = 0;  
            }
            
            if(application.DCCaseNumber__c != null){
                IndividualIdForRequest = mapCaseVsIndividualId.get(String.valueOf(application.DCCaseNumber__c));
                hr.CaseNumber = Integer.valueOf(application.DCCaseNumber__c);
            }else{
                IndividualIdForRequest = individualId;
                hr.ApplicationNumber = Integer.valueOf(application.Name);     
            }
            hr.CorrespondenceCode = correspondenceType;
            hr.CreatedDate= SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
            hr.CreatedUserId =IndividualIdForRequest;            
            hr.DoiAgencyId = 0;
            hr.DoiAgentId =  0;
            hr.MiscellaneousParameters = param;
            hr.PrintMode = 'BP';
            hr.ProgramCode = application.ProgramsApplied__c;
            hr.RequestTriggerStatusCode = 'NEW';
            hr.TriggerSourceCode = 'SF_SSP_SYSTEM_TRG';
            hr.UpdatedDate = SSP_Utility.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
            hr.UpdatedUserId =IndividualIdForRequest;  
            hr.Reqtype = 'InsertCorrespondenceTrigger';
            Map<String,object> obj = new Map<string,object>();
            obj.put('jsonbody', JSON.serialize(hr));
            obj.put(SSP_InterfaceConstants.IS_LOG_INSERTED,false);
            List<object> slist = IntegrationFactory.invokeCallout('SSP_Correspondence',obj);
            
            if(slist != null && slist.size() > 0 && slist[0] != null){
                SSP_CorrespondenceResponseWrapper resp = (SSP_CorrespondenceResponseWrapper)slist[0];
                if(resp.isSuccess){
                    response = 'true';
                    
                }else{
                    response = resp.LogId;
                }
            }
           
             if(slist.size() >1 && slist[1] != null){                 
                    LOG_LogMessage__c objLog = (LOG_LogMessage__c) slist[1];
              
                    lstLogs.add(objLog);
                    
                }
        }
        return response;
    }
    public class queryComponents{
        @AuraEnabled
        public string memberId { get; set;}
        @AuraEnabled
        public String latitude { get; set;}
        @AuraEnabled
        public String longitude { get; set;}
        @AuraEnabled
        public String FirstName { get; set;}
        @AuraEnabled
        public String LastName { get; set;}
        @AuraEnabled
        public String ZipCode { get; set;}
        @AuraEnabled
        public String Organization { get; set;}
    }
    public class contactOrganization{
        @AuraEnabled
        public contact objContact { get; set;}
        @AuraEnabled
        public String FirstName { get; set;}
        @AuraEnabled
        public String LastName { get; set;}
        @AuraEnabled
        public String organizationName { get; set;}
        @AuraEnabled
        public String organizationDataId { get; set;}
        @AuraEnabled
        public String organizationAddressLine1 { get; set;}
        @AuraEnabled
        public String organizationAddressLine2 { get; set;}
        @AuraEnabled
        public String organizationEmail { get; set;}
        @AuraEnabled
        public Boolean isOrganization { get; set;}
        @AuraEnabled
        public String organizationPhone { get; set;}
        @AuraEnabled
        public String organizationContactId { get; set;}
    }
}