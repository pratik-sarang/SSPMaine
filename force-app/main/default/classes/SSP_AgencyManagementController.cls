/*
* classname 	: SSP_AgencyManagementController
* @description 	: A controller class for Agency Management Screen.
* @author 		: Keshav Poduval
* @date 		: May-12-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Keshav Poduval 		May-12-2020			Initial Version
*/

public  without sharing class SSP_AgencyManagementController {
    
     /***************************************************************************************************
* @author       Keshav Poduval
* @date         05/12/2020
* @methodname   getAssisters
* @description  This methods is used to fetch all Assisters within Logged In users Organization
* @return       List<Contact>
*****************************************************************************************************/
    @AuraEnabled
    public static List<Contact> getAssisters(String userId){
        SSP_Utility.isAuthenticatedUser();
        List<Contact> listAssisters = new List<Contact>();
        Set<Id> setContactIdsWithinOrganization = new Set<Id>();
        Set<Contact> setContacts = new Set<Contact>();
        Set<Id> setOrgIds = new Set<Id>();
        
        try {
            User loggedInUser = [SELECT Id, ContactId from user where id = :userId];
            
            if(loggedInUser != null){
                for(AccountContactRelation loggedInACR : [SELECT Id,Contact.FirstName, Contact.LastName,ContactId, AccountId 
                                                          FROM AccountContactRelation 
                                                          WHERE ContactId = :loggedInUser.ContactId AND Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION ])
                {
                    setOrgIds.add(loggedInACR.AccountId);
                }
                
                if(setOrgIds.size()>0){
                    //Find all assisters within the logged in user's organization
                    for(AccountContactRelation acrRecord : [SELECT Id, Contact.FirstName, Contact.LastName,ContactId
                                                            FROM AccountContactRelation WHERE AccountId IN :setOrgIds AND Roles includes (:SSP_GlobalConstants.ASSISTER_ROLE) ])
                    {
                        Contact assisterRecord = new Contact();
                        assisterRecord.FirstName = acrRecord.Contact.FirstName;
                        assisterRecord.LastName = acrRecord.Contact.LastName;
                        assisterRecord.Id = acrRecord.ContactId;
                        setContacts.add(assisterRecord);
                    }
                    listAssisters.addAll(setContacts);
                    
                }
            }
        }catch(exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AgencyManagementController', 'getAssisters', e.getStackTraceString(), true);}
        return listAssisters;
    }
    
    
    
    /**
* @function : getSearchResults -
* @description :1. If case number is given in search parameters invoke callout.
*               2. If application number is given in search parameter search in salesforce.
*               3. If application and casenum is blank and any other field is populated perform both salesforce search and callout
* @param  assignedTo  -   agentId
* @param  firstName   -   agent firstName
* @param  lastName    -   agent lastName
* @param  applicationNum - application Number
* @param  caseNum     -   Case Number
* @Author Keshav Poduval
*/
    
    @AuraEnabled
    public static List<AgencySearchResultWrapper> getSearchResults(
        String assignedTo,
        String firstName,
        String lastName,
        String applicationNum,
        String caseNum
    ) {
        SSP_Utility.isAuthenticatedUser();
        List<AgencySearchResultWrapper> listResultWrapper = new List<AgencySearchResultWrapper>();
        
        Set<String> setAccountIds = new Set<String>();
        
        setAccountIds = getAllClientAccountsWithinOrganization();
        
        //If case number is given in search parameters invoke callout
        if(String.ISNOTBLANK(caseNum)){
            listResultWrapper.addAll(makeCalloutToGetCaseDetails(assignedTo,firstName,lastName,caseNum));
        }
        //If application and casenum is blank and any other field is populated perform both salesforce search and callout
        else if(String.ISNOTBLANK(assignedTo) || String.ISNOTBLANK(firstName) || String.ISNOTBLANK(lastName) || String.ISNOTBLANK(applicationNum)){
            if(setAccountIds != null && setAccountIds.size()>0){
                listResultWrapper.addAll(getSearchResultsBasedOnOtherParams(assignedTo, firstName,lastName,applicationNum, setAccountIds));
            }
            if(String.ISBLANK(applicationNum)){
                listResultWrapper.addAll(makeCalloutToGetCaseDetails(assignedTo,firstName,lastName,caseNum));
            }
        }
        if(listResultWrapper != null && listResultWrapper.size()>0){
            for(Integer i=0;i<listResultWrapper.size();i++){
                listResultWrapper[i].recordId = i;
            }
        }
        
        return listResultWrapper;
        
    }
    
    /***************************************************************************************************
* @author       Keshav Poduval
* @date         05/12/2020
* @methodname   getAllClientContactsWithinOrganization
* @description  This methods is used to fetch all Accounts within Logged In users Organization
* @return       List<AgencySearchResultWrapper>
*****************************************************************************************************/
    private static Set<String> getAllClientAccountsWithinOrganization(){
        Set<String> setAccountIds = new Set<String>();
        Set<Id> setContactIdsWithinOrganization = new Set<Id>();
        Set<Id> setOrgIds = new Set<Id>();
        try{
            User loggedInUser = [SELECT Id, ContactId from user where id = :UserInfo.getUserId()];
            
            if(loggedInUser!= null && loggedInUser.ContactId != null){
                for(AccountContactRelation loggedInACR : [SELECT Id,Contact.FirstName, Contact.LastName,ContactId, AccountId 
                                                          FROM AccountContactRelation 
                                                          WHERE ContactId = :loggedInUser.ContactId AND Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION])
                {
                    setOrgIds.add(loggedInACR.AccountId);
                }
                if(setOrgIds.size()>0){
                    //Find all non citizen contacts within the logged in user's organization
                    for(AccountContactRelation acrRecord : [SELECT Id, Contact.FirstName, Contact.LastName,ContactId,AccountId
                                                            FROM AccountContactRelation WHERE AccountId IN :setOrgIds])
                    {
                        setContactIdsWithinOrganization.add(acrRecord.ContactId);
                    } 
                }
                
                if(setContactIdsWithinOrganization.size()>0){
                    //Find all accounts related to assisters in the org
                    for(AccountContactRelation acrRecord : [SELECT Id, Contact.FirstName, Contact.LastName,ContactId, AccountId
                                                            FROM AccountContactRelation 
                                                            WHERE (ContactId IN :setContactIdsWithinOrganization AND Account.Recordtype.DeveloperName = :SSP_GlobalConstants.APPLICATION AND Roles includes (:SSP_GlobalConstants.ASSISTER_ROLE) ) 
                                                            OR (AccountId IN :setOrgIds AND Contact.Recordtype.DeveloperName = :SSP_GlobalConstants.CITIZEN)
                                                           ])
                    {
                        setAccountIds.add(String.valueOf(acrRecord.AccountId));
                    }
                }
                
            } 
        }catch(exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AgencyManagementController', 'getAllClientAccountsWithinOrganization', e.getStackTraceString(), true);}
        return setAccountIds;
    }
        
  /***************************************************************************************************
* @author       Keshav Poduval
* @date         05/12/2020
* @methodname   getSearchResultsBasedOnOtherParams
* @description  This methods is used to generate search results based on based on assignedTo, firstName and Lastname passed
* @return       List<AgencySearchResultWrapper>
*****************************************************************************************************/  
    private static List<AgencySearchResultWrapper> getSearchResultsBasedOnOtherParams(String assignedTo, String firstName,String lastName, String applicationNum, Set<String> setAccountIdInOrganization){
        List<AgencySearchResultWrapper> listWrapper = new List<AgencySearchResultWrapper>();
        Map<Id,AssisterDetails> mapClientAccIdToAssisterDetails = new Map<Id,AssisterDetails>();
        Set<Id> setClientAccountIds = new Set<Id>();
        try{
            if(String.isNotBlank(firstName)){
                firstName = String.escapeSingleQuotes(firstName);
            }
            if(String.isNotBlank(lastName)){
                lastName = String.escapeSingleQuotes(lastName);
            }
            if(String.isNotBlank(assignedTo)){
                assignedTo = String.escapeSingleQuotes(assignedTo);
            }
            if(String.isNotBlank(applicationNum)){
                applicationNum = String.escapeSingleQuotes(applicationNum);
            }
            
            
            String query = 'SELECT Id, Name,IsHeadOfHousehold__c, SSP_Member__r.FirstName__c, SSP_Member__r.LastName__c,SSP_Member__r.GenderCode__c,'+
                'SSP_Member__r.Age__c, SSP_Member__r.Contact__r.IndividualId__c,SSP_Application__r.Account__c, SSP_Member__r.Contact__c, SSP_Application__r.Name,SSP_Member__r.Contact__r.AccountId '+
                'FROM SSP_ApplicationIndividual__c WHERE IsHeadOfHousehold__c=true AND SSP_Application__r.Recordtype.DeveloperName = \'SSP_Application\' AND SSP_Application__r.Account__c IN :setAccountIdInOrganization and SSP_Application__r.status__c=\'UN\' ' ;
            if(String.isNotBlank(firstName)){
                query +=' AND (SSP_Member__r.FirstName__c LIKE \'%'+firstName+'\' OR SSP_Member__r.FirstName__c LIKE \'%'+firstName+'%\' OR SSP_Member__r.FirstName__c LIKE \''+firstName+'%\')';
            }
            if(String.isNotBlank(lastName)){
                query +=' AND (SSP_Member__r.LastName__c LIKE \'%'+lastName+'\' OR SSP_Member__r.LastName__c LIKE \'%'+lastName+'%\' OR SSP_Member__r.LastName__c LIKE \''+lastName+'%\')';
            }
            if(String.isNotBlank(applicationNum)){
                query += ' AND SSP_Application__r.Name =:applicationNum';
            }
            if(String.isNotBlank(assignedTo)){
                for(AccountContactRelation acrRecord :[SELECT Id,AccountId,CreatedDate,ContactId,Contact.FirstName,Contact.Lastname 
                                                       FROM AccountContactRelation 
                                                       WHERE ContactId =:assignedTo AND Roles includes (:SSP_GlobalConstants.ASSISTER_ROLE) AND Account.Recordtype.Name = :SSP_GlobalConstants.APPLICATION])
                {
                    Datetime assignedDate = acrRecord.CreatedDate;
                    if(!mapClientAccIdToAssisterDetails.containsKey(acrRecord.AccountId)){
                        mapClientAccIdToAssisterDetails.put(acrRecord.AccountId, new AssisterDetails(acrRecord.ContactId,acrRecord.Contact.FirstName,acrRecord.Contact.Lastname,
                                                                                                   assignedDate.format(SSP_GlobalConstants.DATEFORMAT)));
                    }
                    setClientAccountIds.add(acrRecord.AccountId);
                }
            }
            List<SSP_ApplicationIndividual__c> listAppIndiv = (List<SSP_ApplicationIndividual__c>)Database.query(query);
            if(listAppIndiv != null && listAppIndiv.size()>0){
                for(SSP_ApplicationIndividual__c sspAppIndiv : listAppIndiv)
                {
                    if(sspAppIndiv.IsHeadOfHousehold__c){
                        setClientAccountIds.add(sspAppIndiv.SSP_Application__r.Account__c);
                    }
                }
                if(setClientAccountIds.size()>0){
                    for(AccountContactRelation acrRecord :[SELECT Id,AccountId,CreatedDate,ContactId,Contact.FirstName,Contact.Lastname 
                                                           FROM AccountContactRelation 
                                                           WHERE AccountId IN :setClientAccountIds AND Roles includes (:SSP_GlobalConstants.ASSISTER_ROLE)])
                    {
                        Datetime assignedDate = acrRecord.CreatedDate;
                        if(!mapClientAccIdToAssisterDetails.containsKey(acrRecord.AccountId) && String.isBlank(assignedTo)){
                            mapClientAccIdToAssisterDetails.put(acrRecord.AccountId, new AssisterDetails(acrRecord.ContactId,acrRecord.Contact.FirstName,acrRecord.Contact.Lastname,
                                                                                                       assignedDate.format(SSP_GlobalConstants.DATEFORMAT)));
                        }
                    }
                    Integer rowCounter = 0;
                    for(SSP_ApplicationIndividual__c sspAppIndiv : listAppIndiv)
                    {
                        if(mapClientAccIdToAssisterDetails.containsKey(sspAppIndiv.SSP_Application__r.Account__c) && mapClientAccIdToAssisterDetails.get(sspAppIndiv.SSP_Application__r.Account__c) != null)
                        {
                            AgencySearchResultWrapper resultWrapper = new AgencySearchResultWrapper();
                            resultWrapper.clientDetails = new ClientDetails(sspAppIndiv.SSP_Member__r.FirstName__c,
                                                                            sspAppIndiv.SSP_Member__r.LastName__c,
                                                                            sspAppIndiv.SSP_Member__r.GenderCode__c,
                                                                            Integer.valueOf(sspAppIndiv.SSP_Member__r.Age__c),
                                                                            sspAppIndiv.SSP_Application__r.Name,
                                                                            null,
                                                                            String.valueOf(sspAppIndiv.SSP_Application__r.Account__c),
                                                                            null,
                                                                            String.valueOf(sspAppIndiv.SSP_Member__r.Contact__r.AccountId));//Defect #398099
                            resultWrapper.assignedTo = mapClientAccIdToAssisterDetails.get(sspAppIndiv.SSP_Application__r.Account__c);
                            rowCounter++;
                            resultWrapper.recordId = rowCounter;
                            resultWrapper.isSelected = false;
                            listWrapper.add(resultWrapper);
                        }
                        
                    }
                }
            }
        }catch(exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AgencyManagementController', 'getSearchResultsBasedOnOtherParams', e.getStackTraceString(), true);}
        return listWrapper;
    }
      /***************************************************************************************************
* @author       Keshav Poduval
* @date         05/12/2020
* @methodname   makeCalloutToGetCaseDetails
* @description  This methods is used to make callouts to WP with miscellaneous parameter
* @return       List<AgencySearchResultWrapper>
*****************************************************************************************************/  
    public static List<AgencySearchResultWrapper> makeCalloutToGetCaseDetails(String assignedTo, String firstName,String lastName,String caseNum)
    {
        List<AgencySearchResultWrapper> listSearchResultWrapper = new List<AgencySearchResultWrapper>();
        Contact assignedToContact;
        AccountContactRelation assisterACR;
        try{
            if(String.isNotBlank(assignedTo)){
                assignedToContact = [SELECT Id,Name From Contact WHERE Id = :assignedTo];
            }
            
            String userId = UserInfo.getUserId();
            Contact conRec = [Select Id FROM Contact where ID IN (SELECT ContactId FROM User WHERE Id =:userId)];
            
            AccountContactRelation orgAccount = [SELECT Id,Account.DCDataId__c,DCContactId__c,AccountId FROM AccountContactRelation WHERE ContactId = :conRec.Id AND Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION AND (Account.DCDataId__c != null OR DCContactId__c != null) LIMIT 1];
            
            if(String.isNotBlank(assignedTo)){
                assisterACR = [SELECT Id,Account.DCDataId__c,DCContactId__c FROM AccountContactRelation WHERE ContactId = :assignedTo AND AccountId = :orgAccount.AccountId LIMIT 1];
            }
            
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.NON_CITIZEN_SEARCH_CASE;
            reqWrapper.KeyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
            if(String.isNotBlank(firstName)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('FirstName',firstName));
            }
            if(String.isNotBlank(lastName)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('LastName',lastName));
            }
            if(String.isNotBlank(caseNum)){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('CaseNumber',caseNum));
            }
            if(assignedToContact != null){
                reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('AssisterName',String.valueOf(assisterACR.DCContactId__c)));
            }
            
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('ModuleName','Agency Management'));
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('AssistedbyRole','Agency_Admin'));
            reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper('organizationId',String.valueOf(orgAccount.Account.DCDataId__c)));
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
            
            SSP_AckResponseWRapper callOutResponse=responseWrapper.ACKRESPONSE;
            
            //RSSP_DC_Wrapper sampleResponse=(RSSP_DC_Wrapper)JSON.deserialize(sampleTestJSON, RSSP_DC_Wrapper.class);
            
            NonCitizenSearchCasePayloadWrapper nonCitizenInfo=responseWrapper.nonCitizenSearchCasePayload;
            if(nonCitizenInfo.CaseInfo != null && responseWrapper.ACKRESPONSE == null){
                for(NonCitizenSearchCasePayloadWrapper.CaseInfoWrapper caseInfoWrapRecord:nonCitizenInfo.CaseInfo){ 
                    AgencySearchResultWrapper agentSearchWrapper = new AgencySearchResultWrapper();
                    agentSearchWrapper.recordId = 1;
                    Date dob = date.valueOf(caseInfoWrapRecord.BirthDate);
                    Integer age = (dob.daysBetween(System.today()))/365; 
                    String dateFormatted = '';
                    if(caseInfoWrapRecord.LastupdatedDate != null){
                        String assignedDate = caseInfoWrapRecord.LastupdatedDate;
                        List<String> dateParts = assignedDate.split('-');
                        Datetime dateWithTime = Datetime.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
                        dateFormatted = dateWithTime.format(SSP_GlobalConstants.DATEFORMAT);
                    }
                    String indivId = caseInfoWrapRecord.IndividualId;
                    agentSearchWrapper.ClientDetails = new ClientDetails(caseInfoWrapRecord.FirstName,caseInfoWrapRecord.LastName,caseInfoWrapRecord.GenderCode,age,null,String.valueOf(caseInfoWrapRecord.CaseNumber),null,indivId, null);
                    //Start-Added as part of Defect-390559
                    String sAssisterFirstName = '';
                    String sAssisterLastName = '';
                    if(String.isNotBlank(caseInfoWrapRecord.AssisterName)) {
                        List<String> lstName = caseInfoWrapRecord.AssisterName.contains(' ') ? caseInfoWrapRecord.AssisterName.split(' '):new List<String>{caseInfoWrapRecord.AssisterName};
                        sAssisterFirstName = !lstName.isEmpty() && String.isNotBlank(lstName[0]) ? lstName[0] : '';
                        sAssisterLastName = caseInfoWrapRecord.AssisterName.contains(' ') ? caseInfoWrapRecord.AssisterName.substringAfterLast(' ') : '';
                    }
                    //End-Added as part of Defect-390559
                    agentSearchWrapper.assignedTo = new AssisterDetails(null,sAssisterFirstName,sAssisterLastName,dateFormatted); //Added firstName & LastName for Defect-390559
                    listSearchResultWrapper.add(agentSearchWrapper);
                }
            }
            
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AgencyManagementController', 'makeCalloutToGetCaseDetails', e.getMessage() + ' ' + e.getStackTraceString() , true);
        }
        return listSearchResultWrapper;
    }
    
 /***************************************************************************************************
* @author       Keshav Poduval
* @date         05/12/2020
* @methodname   assignNewAssisters
* @description  This methods is used to change assisters within salesforce and make callouts for case assignment
* @return       
*****************************************************************************************************/    
    @AuraEnabled
    public static SSP_LightningResponse assignNewAssisters(List<AgencySearchResultWrapper> listSelectedWrappers, String newAssignedTo){
        SSP_LightningResponse mapResponse = new SSP_LightningResponse();//388705
        try{
            SSP_Utility.isAuthenticatedUser();
            
            mapResponse.put('bIsSuccess',false);//388705
            List<AgencySearchResultWrapper> listSelectedCaseRecords = new List<AgencySearchResultWrapper>();
            List<AgencySearchResultWrapper> listSelectedAppRecords = new List<AgencySearchResultWrapper>(); //Defect - 387442
            Set<String> setAppNo = new Set<String>(); //Defect - 387442
            List<AccountContactRelation> listInsertACR = new List<AccountContactRelation>();
            List<AccountContactRelation> listDeleteACR = new List<AccountContactRelation>();
            Map<Id,Id> mapAppAccountToAssisterConId = new Map<Id,Id>();
            Map<Id, Id> mapMemberAccountId = new Map<Id, Id>();
            
            //Segregate application and cases
            for(AgencySearchResultWrapper selectedWrapper : listSelectedWrappers){
                //update application account ACR
                if(String.isNotBlank(selectedWrapper.clientDetails.appNumber)){
                    if(selectedWrapper.clientDetails.clientAccountId != null && 
                       !mapAppAccountToAssisterConId.containsKey(selectedWrapper.clientDetails.clientAccountId)){
                           mapAppAccountToAssisterConId.put(selectedWrapper.clientDetails.clientAccountId,selectedWrapper.assignedTo.contactId);
                           listSelectedAppRecords.add(selectedWrapper); //Defect - 387442
                           setAppNo.add(selectedWrapper.clientDetails.appNumber); //Defect - 387442
                       }
                       /*[Suresh] Defect #398099 Starts */
                       if(String.isNotBlank(selectedWrapper.clientDetails.memberAccountId)){
                           mapMemberAccountId.put(selectedWrapper.clientDetails.memberAccountId, selectedWrapper.assignedTo.contactId);
                       }
                    /*[Suresh] Defect #398099 Ends */
                    
                }else if(String.isNotBlank(selectedWrapper.clientDetails.caseNumber)){
                    //make separate wrapper for case recordtype
                    listSelectedCaseRecords.add(selectedWrapper);
                }
            }
            if(listSelectedCaseRecords.size()>0){
                //make callout for new assignment
                mapResponse = updateCaseAssignment(listSelectedCaseRecords,newAssignedTo);
            }
            
            if(mapAppAccountToAssisterConId != null && mapAppAccountToAssisterConId.size()>0){
                //Find ACR for the client accounts selected
                for(AccountContactRelation acrRecord : [SELECT Id,AccountId, ContactId, Contact.AccountId, Roles from AccountContactRelation
                                                        WHERE (AccountId IN :mapAppAccountToAssisterConId.keySet() AND Roles includes (:SSP_GlobalConstants.ASSISTER_ROLE)) OR (AccountId IN: mapMemberAccountId.keySet())])//[Suresh] added filter as part of defect #398099
                {
                    
                    if(acrRecord.ContactId == mapAppAccountToAssisterConId.get(acrRecord.AccountId)){
                        AccountContactRelation newAppAcr = new AccountContactRelation(AccountId = acrRecord.AccountId,
                                                                                   ContactId = Id.valueOf(newAssignedTo),
                                                                                   Roles = (SSP_GlobalConstants.ASSISTER_ROLE));
                        listInsertACR.add(newAppAcr);
                        listDeleteACR.add(acrRecord);
                    }
                    //Defect #398099
                    if(mapMemberAccountId.get(acrRecord.AccountId) != null && acrRecord.ContactId == mapMemberAccountId.get(acrRecord.AccountId) ){
                        AccountContactRelation newMemberAcr = new AccountContactRelation(AccountId = acrRecord.AccountId,
                                                                                   ContactId = Id.valueOf(newAssignedTo));
                        listInsertACR.add(newMemberAcr);
                        listDeleteACR.add(acrRecord);
                        
                    }                   
                    
                }
                if(listDeleteACR.size()>0){
                    ESAPI.accessController().setSharingMode(SFDCAccessController.SharingMode.WITHOUT); //Added as part of Defect - 388314
                    ESAPI.accessController().deleteAsUser(listDeleteACR);
                }
                if(listInsertACR.size()>0){
                    SSP_GenericWOSharingDMLHelper.insertRecords(listInsertACR, new List<String>{'AccountId','ContactId','Roles'}); //Added as part of Defect - 388314
                    //make callout for Correspondence creation
                    sendApplicationCorrespondence(setAppNo, JSON.serialize(listSelectedAppRecords), newAssignedTo); //Defect - 387442
                }
                mapResponse.put('bIsSuccess',true);//388705
            }
            
        }catch(exception e){
            LOG_LogMessage__c logRecord = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AgencyManagementController', 'assignNewAssisters', e.getStackTraceString(), true);
            mapResponse.put('error',logRecord.Name);//388705
        }
        return mapResponse;
    }
    
  /***************************************************************************************************
* @author       Keshav Poduval
* @date         05/12/2020
* @methodname   updateCaseAssignment
* @description  This methods is used to make callout to change assisters in worker portal
* @return       
*****************************************************************************************************/       
    public static SSP_LightningResponse updateCaseAssignment(List<AgencySearchResultWrapper> listSelectedCaseRecords,String newAssignedTo){
        SSP_LightningResponse mapResponse = new SSP_LightningResponse();
        mapResponse.put('bIsSuccess',false);//388705
        String userId = UserInfo.getUserId();
        Contact conRec = [Select Id FROM Contact where ID IN (SELECT ContactId FROM User WHERE Id =:userId)];
        
        AccountContactRelation orgAccount = [SELECT Id,Account.DCDataId__c,DCContactId__c,AccountId 
                                             FROM AccountContactRelation 
                                             WHERE ContactId = :conRec.Id AND Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION AND Roles!=null LIMIT 1]; //Defect-389691
        
        AccountContactRelation conAssister = [Select Id,DCContactId__c 
                                              FROM AccountContactRelation 
                                              WHERE ContactId = :newAssignedTo AND AccountId = :orgAccount.AccountId];
        
        String result = '';
        String ErrorId = ''; 
        SSP_UpdateAgentAssisterRequestWrapper objRequest = new  SSP_UpdateAgentAssisterRequestWrapper();
        List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel> listChildObj = new List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel>();
        List<LOG_LogMessage__c> lstLogs = new List<LOG_LogMessage__c>();
        objRequest.Operation = 'UpdateAll';
        
        for(AgencySearchResultWrapper resultWrapper : listSelectedCaseRecords){
            //397732
             List<String> caseNumbers = new List<String>();
            if(resultWrapper.clientDetails.caseNumber.contains(',')){
                caseNumbers = resultWrapper.clientDetails.caseNumber.split(',');
            }else{
                caseNumbers.add(resultWrapper.clientDetails.caseNumber);
            }
            for(String caseNo : caseNumbers){
            SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel objChild = new SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel();
            objChild.AgencyId = String.valueOf(orgAccount.Account.DCDataId__c);//logged in users org Id
            objChild.NewAssignment = String.valueOf(conAssister.DCContactId__c);
            objChild.CaseNumber = caseNo;
            objChild.IndividualId = resultWrapper.clientDetails.individualId;//'890010089';
            objchild.IsAssisterUpdate = 'true';
            objchild.IsTriggeredbyAgencyAdmin = true; //Defect - 387442. Keep true only to create correspondence (HBE18 implementation)
            listChildObj.add(objChild);
            }
            
        }
        objRequest.DCAgencyIndividualCaseAssociationModel = listChildObj;
        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objRequest) };
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPUpdateAgentAssister_METADATANAME , objResponse);
		
        if(lstData != null && (!lstData.isEmpty())){
            SSP_UpdateAgentAssisterResWrapper objResult = (SSP_UpdateAgentAssisterResWrapper)lstData[0];
            
            if(objResult.AckResponse != null && objResult.AckResponse.Success){ //Defect-389691
                result = 'true';
                mapResponse.put('bIsSuccess',true);//388705
            }else if ((objResult.isSFFailure != null && (objResult.isSFFailure)) || (objResult.AckResponse != null  && objResult.AckResponse.Error != null)){
                if(objResult.AckResponse !=null && objResult.AckResponse.Error.CHFSExceptionId != null){
                    result = objResult.AckResponse.Error.CHFSExceptionId;
                    mapResponse.put('error',result);//388705
                }else if(objResult.AckResponse != null && objResult.AckResponse.Error.ErrorCode != null){
                    result = objResult.AckResponse.Error.ErrorCode;
                    mapResponse.put('error',result);//388705
                }
                
            }
            if(lstData.size() >1 && lstData[1] != null){                   
                LOG_LogMessage__c objLog = (LOG_LogMessage__c) lstData[1];
                lstLogs.add(objLog);
                
                ESAPI.accessController().insertAsUser(new List<LOG_LogMessage__c>{lstLogs[0]}, SSP_Utility.getFieldsNamesObject(lstLogs[0]));
            }
        }
        return mapResponse;
    }

    //Start - Added as part of Defect - 387442
    /***************************************************************************************************
    * @author       Ashwin Kasture
    * @date         08/25/2020
    * @methodname   sendApplicationCorrespondence
    * @description  This methods is used to make callout to create Application Correspondence (HBE-18 implementation)
    * @return       void
    *****************************************************************************************************/ 
    @future(callout=true)
    public static void sendApplicationCorrespondence(Set<String> setAppNo, String strSelectedAppRecords, String newAssignedTo) {
        try {
            List<AgencySearchResultWrapper> listSelectedAppRecords = (List<AgencySearchResultWrapper>) JSON.deserialize(strSelectedAppRecords, List<AgencySearchResultWrapper>.class);
            AccountContactRelation orgAccount = new AccountContactRelation();
            AccountContactRelation conAssister = new AccountContactRelation();
            List<AccountContactRelation> lstAuthRep = new List<AccountContactRelation>();
            Map<String, List<AccountContactRelation>> mapAccIdVsLstACR = new Map<String, List<AccountContactRelation>>();
            List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
            Map<String, SSP_ApplicationIndividual__c> mapAppNoVsAppInd = new Map<String, SSP_ApplicationIndividual__c>();
            Set<String> setAppAccountId = new Set<String>();
            Set<String> setAuthRep = new Set<String>{SSP_GlobalConstants.INDIVIDUAL_AUTH_REP,SSP_GlobalConstants.ORGANIZATION_AUTH_REP};

            String userId = UserInfo.getUserId();
            Contact conRec = [Select Id FROM Contact where ID IN (SELECT ContactId FROM User WHERE Id =:userId)];
            
            if(conRec != null) {
                orgAccount = [SELECT Id,Account.DCDataId__c,DCContactId__c,AccountId 
                            FROM AccountContactRelation 
                            WHERE ContactId = :conRec.Id AND Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION AND Roles!=null LIMIT 1]; //Defect-389691
            }
            if(orgAccount != null) {
                conAssister = [Select Id,DCContactId__c 
                            FROM AccountContactRelation 
                            WHERE ContactId =:newAssignedTo AND AccountId =:orgAccount.AccountId];
                
                //To retrive the Application specific data
                lstAppInd = [Select Id, SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.MailingCity__c, 
                            SSP_Member__r.MailingAddressLine1__c, SSP_Member__r.MailingAddressLine2__c, SSP_Member__r.MailingZipCode5__c, SSP_Member__r.MailingStateCode__c,
                            SSP_Member__r.PhysicalAddressLine1__c, SSP_Member__r.PhysicalAddressLine2__c, SSP_Member__r.PhysicalCity__c, SSP_Member__r.PhysicalZipCode5__c,
                            SSP_Member__r.PhysicalStateCode__c,SSP_Member__r.PreferredNotificationMethodCode__c,SSP_Application__r.Name,SSP_Application__r.Account__c,
                            SSP_Member__r.PreferredWrittenLanguageCode__c,SSP_Member__r.IndividualId__c
                            FROM SSP_ApplicationIndividual__c
                            WHERE SSP_Application__r.Name IN:setAppNo AND IsHeadOfHouseHold__c = true];
                for(SSP_ApplicationIndividual__c objAppInd: lstAppInd) {
                    mapAppNoVsAppInd.put(objAppInd.SSP_Application__r.Name,objAppInd);
                    setAppAccountId.add(objAppInd.SSP_Application__r.Account__c);
                }

                if(!lstAppInd.isEmpty()) {
                    lstAuthRep = [SELECT Id,AccountId,DCRepresentativeId__c,Contact.PreferredCommunicationMethod__c,Contact.PreferredLanguageCode__c,Contact.FirstName,
                                Contact.LastName,Contact.MiddleName,Street__c,AddressLine2__c,City__c,SSP_State__c,Zipcode5__c
                                FROM AccountContactRelation 
                                WHERE AccountId IN:setAppAccountId AND Roles IN:setAuthRep];
                    for(AccountContactRelation objAuthRep: lstAuthRep) {
                        if(mapAccIdVsLstACR.containsKey(objAuthRep.AccountId)) {
                                List<AccountContactRelation> lstACR = mapAccIdVsLstACR.get(objAuthRep.AccountId);
                                lstACR.add(objAuthRep);
                                mapAccIdVsLstACR.put(objAuthRep.AccountId, lstACR);
                        } else {
                            mapAccIdVsLstACR.put(objAuthRep.AccountId, new List<AccountContactRelation> { objAuthRep });
                        }
                    }
                }

                String result = '';
                SSP_UpdateAgentAssisterRequestWrapper objRequest = new  SSP_UpdateAgentAssisterRequestWrapper();
                List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel> listChildObj = new List<SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel>();
                List<LOG_LogMessage__c> lstLogs = new List<LOG_LogMessage__c>();
                objRequest.Operation = 'UpdateAll';
                
                for(AgencySearchResultWrapper resultWrapper : listSelectedAppRecords){
                    SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel objChild = new SSP_UpdateAgentAssisterRequestWrapper.cls_DCAgencyIndividualCaseAssociationModel();
                    objChild.AgencyId = String.valueOf(orgAccount.Account.DCDataId__c);
                    objChild.NewAssignment = String.valueOf(conAssister.DCContactId__c);
                    objChild.ApplicationNumber = Integer.valueOf(resultWrapper.clientDetails.appNumber);
                    //objChild.IndividualId = resultWrapper.clientDetails.individualId; // Need to talk with keshav Individual Id not getting passed?
                    objchild.IsAssisterUpdate = 'true';
                    
                    objchild.IsTriggeredbyAgencyAdmin = true; //Keep true only to create correspondence (HBE18 implementation)
                    //Set HOH Client Details
                    if(mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber) != null && mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__c != null) {
                        objchild.ClientFirstName = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.FirstName__c;
                        objchild.ClientMI = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MiddleInitial__c;
                        objchild.ClientLastName = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.LastName__c;
                        objChild.IndividualId = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.IndividualId__c;
                        SSP_UpdateAgentAssisterRequestWrapper.cls_ClientAddress objClientAddress = new SSP_UpdateAgentAssisterRequestWrapper.cls_ClientAddress();
                        objClientAddress.AddressLine1 = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingAddressLine1__c != null ?
                        mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingAddressLine1__c: mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.PhysicalAddressLine1__c;

                        objClientAddress.AddressLine2 = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingAddressLine2__c != null ?
                        mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingAddressLine2__c: mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.PhysicalAddressLine2__c;

                        objClientAddress.City = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingCity__c != null ?
                        mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingCity__c: mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.PhysicalCity__c;

                        objClientAddress.StateCode = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingStateCode__c != null ?
                        mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingStateCode__c: mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.PhysicalStateCode__c;

                        objClientAddress.ZipCode5 = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingZipCode5__c != null ?
                        mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.MailingZipCode5__c: mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.PhysicalZipCode5__c;

                        objClientAddress.DeliveryPreference = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.PreferredNotificationMethodCode__c; // Need to check with Rama
                        objClientAddress.LanguagePreference = mapAppNoVsAppInd.get(resultWrapper.clientDetails.appNumber).SSP_Member__r.PreferredWrittenLanguageCode__c; // Need to check with Rama

                        objchild.ClientAddress = objClientAddress;
                    }
                    
                    //Set Auth Rep Details
                    if(mapAccIdVsLstACR.get(resultWrapper.clientDetails.clientAccountId) != null && !mapAccIdVsLstACR.get(resultWrapper.clientDetails.clientAccountId).isEmpty()) {
                        SSP_UpdateAgentAssisterRequestWrapper.cls_AuthRepDetails objAuthRepDetails = new SSP_UpdateAgentAssisterRequestWrapper.cls_AuthRepDetails();
                        List<SSP_UpdateAgentAssisterRequestWrapper.cls_AuthRepDetailsArray> lstAuthRepDetails = new List<SSP_UpdateAgentAssisterRequestWrapper.cls_AuthRepDetailsArray>();

                        List<AccountContactRelation> lstACR = mapAccIdVsLstACR.get(resultWrapper.clientDetails.clientAccountId);
                        for(AccountContactRelation objACR: lstACR) {
                            SSP_UpdateAgentAssisterRequestWrapper.cls_AuthRepDetailsArray objAuthRep = new SSP_UpdateAgentAssisterRequestWrapper.cls_AuthRepDetailsArray();
                            objAuthRep.AuthRepFirstname = objACR.Contact.FirstName; 
                            objAuthRep.AuthRepMiddleIntial = objACR.Contact.MiddleName;
                            objAuthRep.AuthRepLastName = objACR.Contact.LastName;
                            objAuthRep.RepresentativeId = objACR.DCRepresentativeId__c != null ? Integer.valueOf(objACR.DCRepresentativeId__c):0;
                            //objAuthRep.AuthRepDeliveryPreference = objACR.Contact.PreferredCommunicationMethod__c;
                            objAuthRep.AuthRepDeliveryPreference = null;//objACR.Contact.PreferredLanguageCode__c; // Rama to check with correspondence team
                            objAuthRep.AuthRepLanguagePreference = objACR.Contact.PreferredLanguageCode__c; // Rama to check with correspondence team
                            
                            SSP_UpdateAgentAssisterRequestWrapper.cls_ClientAddress objAuthRepAddress = new SSP_UpdateAgentAssisterRequestWrapper.cls_ClientAddress();
                            objAuthRepAddress.AddressLine1 = objACR.Street__c;
                            objAuthRepAddress.AddressLine2 = objACR.AddressLine2__c;
                            objAuthRepAddress.City = objACR.City__c;
                            objAuthRepAddress.StateCode = objACR.SSP_State__c;
                            objAuthRepAddress.ZipCode5 = objACR.Zipcode5__c;

                            objAuthRep.AuthRepAddress = objAuthRepAddress;
                            lstAuthRepDetails.add(objAuthRep);
                        }
                        objAuthRepDetails.AuthRepDetails = lstAuthRepDetails;
                        objChild.AuthRepDetails = objAuthRepDetails;
                    }
                    listChildObj.add(objChild);
                }
                objRequest.DCAgencyIndividualCaseAssociationModel = listChildObj;
                Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objRequest) };
                List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPUpdateAgentAssister_METADATANAME , objResponse);
                if(lstData != null && (!lstData.isEmpty())) {
                    SSP_UpdateAgentAssisterResWrapper objResult = (SSP_UpdateAgentAssisterResWrapper)lstData[0];
                    
                    if(objResult.AckResponse != null && objResult.AckResponse.Success){ //Defect-389691
                        result = 'true';
                    }else if ((objResult.isSFFailure != null && (objResult.isSFFailure)) || (objResult.AckResponse != null  && objResult.AckResponse.Error != null)){
                        if(objResult.AckResponse != null && objResult.AckResponse.Error.CHFSExceptionId != null){
                            result = objResult.AckResponse.Error.CHFSExceptionId;
                        }else if(objResult.AckResponse != null && objResult.AckResponse.Error.ErrorCode != null){
                            result = objResult.AckResponse.Error.ErrorCode;
                        }
                        
                    }
                    //Add response in Log
                    if(lstData.size() >1 && lstData[1] != null) {
                        LOG_LogMessage__c objLog = (LOG_LogMessage__c) lstData[1];
                        lstLogs.add(objLog);
                        
                        ESAPI.accessController().insertAsUser(new List<LOG_LogMessage__c>{lstLogs[0]}, SSP_Utility.getFieldsNamesObject(lstLogs[0]));
                    }
                }
            }
        } catch(exception e) {
                LOG_LogMessage__c logRecord = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_AgencyManagementController', 'sendApplicationCorrespondence', e.getMessage()+'\n'+e.getStackTraceString(), true);
        }
    }
    //End - Added as part of Defect - 387442

    public class AgencySearchResultWrapper {
        @AuraEnabled
        public Integer recordId{get;set;}
        @AuraEnabled
        public ClientDetails clientDetails{get;set;}
        
        @AuraEnabled
        public AssisterDetails assignedTo{get;set;}
        @AuraEnabled
        public Boolean isSelected{get;set;}
    }
    
    public class ClientDetails {
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String lastName{get;set;}
        @AuraEnabled
        public String gender{get;set;}
        @AuraEnabled
        public Integer age{get;set;}
        @AuraEnabled
        public String caseNumber{get;set;}
        @AuraEnabled
        public String appNumber{get;set;}
        @AuraEnabled
        public String clientAccountId{get;set;}
        @AuraEnabled
        public String individualId{get;set;}
        @AuraEnabled
        public String memberAccountId{get;set;}
        
        public ClientDetails(){
            
        }
        
        public ClientDetails(String firstName, String lastName, String gender, Integer age, String appNumber, String caseNumber, String clientAccountId, String individualId, String memberAccountId){
            this.firstName = firstName;
            this.lastName = lastName;
            this.gender = gender;
            this.age = age;
            this.caseNumber = caseNumber;
            this.appNumber = appNumber;
            this.clientAccountId = clientAccountId;
            this.individualId = individualId;
            this.memberAccountId = memberAccountId;
        }
    }
    
    public class AssisterDetails {
        @AuraEnabled
        public String contactId{get;set;}
        @AuraEnabled
        public String firstName{get;set;}
        @AuraEnabled
        public String lastName{get;set;}
        @AuraEnabled
        public String assignmentStartDate{get;set;}
        
        public AssisterDetails(){
            
        }
        
        public AssisterDetails(String contactId, String firstName, String lastName, String assignmentStartDate){
            this.contactId = contactId;
            this.firstName = firstName;
            this.lastName = lastName;
            this.assignmentStartDate = assignmentStartDate;
        }
    }
    
    
    
}