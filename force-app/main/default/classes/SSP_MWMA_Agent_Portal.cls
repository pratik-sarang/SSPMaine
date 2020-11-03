/**
* Class        :  SSP_MWMA_Agent_Portal 
* Description  :  SSP_MWMA_Agent_Portal
* @author      :  Deloitte
* @date        :  
* MODIFICATION LOG:
* DEVELOPER                         DATE                               DESCRIPTION
* -----------------------------------------------------------------------------------------------------------   
* Srikanth                     06/15/2020                              Initial version
**/
global class SSP_MWMA_Agent_Portal{
    
    public class ServiceException extends Exception{}
    
    global class requestWrapper{
        webservice string PortalSource;
        webservice string IdentifierType;
        webservice string IdentifierValue;
        webservice integer DOIAgentId;
        webservice string FirstName;
        webservice string LastName;
        webservice string MiddleInitial;
        webservice date DOB;
        webservice string SuffixCode;
        webservice string CountyCode;
        webservice Integer LoggedinUserid;
        webservice Integer LoggedInUserIdsOrgId;
        webservice string LoggedInUserRole;
    }
    
    global class responseWrapper{
        webservice list<SSP_ApplicationIndividual__c> lstApplicationIndividualSspMembers;
        webservice list<SSP_ApplicationIndividual__c> lstApplicationIndividualsHouseHold;
        webservice List<SSP_Relationship__c>  lstRelationship;
        webservice List<SSP_InsuranceCoveredIndiv__c> lstinsuranceCovered;
        webservice String CustomerType;
        webservice integer DOIAgentId;
        webservice integer DOIAgencyID;
        webservice string StatusCode;
        webservice string Status;
        webservice string StatusDescription;
    }
    
    webservice static responseWrapper getSearchResults(requestWrapper req) {
        
        responseWrapper resp = new responseWrapper();
        
            try{
                Set<Id> setOrganizationIds = new set<Id>();
                set<id> setOrganizationcontacts = new set<id>();
                set<Id> caseAccounts = new set<Id>();
                set<Id> setSSPMembers = new set<Id>();
                set<Id> setHouseHoldMembers = new set<Id>();
                Integer acrId;
                list<SSP_ApplicationIndividual__c> lstApplicationIndividualSspMembers = new list<SSP_ApplicationIndividual__c>();
                list<SSP_ApplicationIndividual__c> lstApplicationIndividuals = new list<SSP_ApplicationIndividual__c>();
                
                if(req != null && req.DOIAgentId != null){
                    AccountContactRelation acrObj = [SELECT Id,Account.DCDataId__c FROM AccountContactRelation WHERE DCContactId__c =: req.DOIAgentId AND Roles INCLUDES ('Insurance_Agent') AND Account.DCDataId__c!=null LIMIT 1 ];
                    If(acrObj ==null){
                        resp.StatusCode = '2';
                        resp.Status = 'FAILURE';
                        resp.StatusDescription = 'No Search results';
                        return resp;
                    }
                    acrId = Integer.valueOf(acrObj.Account.DCDataId__c);
                    
                    //Get all the organizations related to the agent coming from request
                    for(AccountContactRelation scr : [Select Id,DCContactId__c,AccountId,ContactId,Roles
                                                      FROM AccountContactRelation WHERE DCContactId__c=: req.DOIAgentId ]){
                                                          setOrganizationIds.add(scr.AccountId);
                                                      }
                    
                    //Get all the contacts related to the organization queried above
                    RecordType objContactRecordType = GeneralUtility.fetchRecordType('Non_Citizen', 'Contact');
                    for(AccountContactRelation scr : [Select Id,DCContactId__c,AccountId,ContactId,Roles
                                                      FROM AccountContactRelation WHERE AccountId IN :setOrganizationIds AND Contact.RecordtypeId =: objContactRecordType.Id ]){ 
                                                          setOrganizationcontacts.add(scr.ContactId);
                                                      }
                    } else if(req != null && req.LoggedinUserid != null && req.LoggedInUserRole == 'Internal') {
                        acrId = req.LoggedInUserIdsOrgId;
                    } else if(req != null && req.LoggedinUserid != null && req.LoggedInUserRole != 'Internal') {
                    
                    for(AccountContactRelation scr : [Select Id,DCContactId__c,AccountId,ContactId,Roles,Account.DCDataId__c
                                                      FROM AccountContactRelation WHERE Account.DCDataId__c != null AND Account.DCDataId__c =: req.LoggedInUserIdsOrgId ]){
                                                          setOrganizationcontacts.add(scr.ContactId);
                                                      }
                    acrId = req.LoggedInUserIdsOrgId;
                    
                    } else {
                        resp.StatusCode = '2';
                        resp.Status = 'FAILURE';
                        resp.StatusDescription = 'LoggedInUserIdsOrgId or LoggedinUserid or LoggedInUserRole or DOIAgentId is null';
                        return resp;
                    }
                
                //get  all case accounts related to agents with in the organizations captured above
                RecordType objAccountRecordType = GeneralUtility.fetchRecordType('Application', 'Account');
                
                for(AccountContactRelation scr : [Select Id,DCContactId__c,AccountId,Roles
                                                  FROM AccountContactRelation WHERE ContactId IN :setOrganizationcontacts AND Account.RecordTypeId =: objAccountRecordType.Id ]){
                                                      caseAccounts.add(scr.AccountId);
                                                  }
                
 
                String query = 'SELECT Id,MemberProgramsApplied__c,SSP_Member__r.IndividualId__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c,SSP_Member__r.BirthDate__c,SSP_Member__r.MaidCardNumber__c,toLabel(SSP_Member__r.PhysicalCountyCode__c),SSP_Member__r.SSN__c,SSP_Application__r.DCCaseNumber__c,SSP_Application__r.Name,SSP_Application__r.Status__c,SSP_Application__r.CreatedDate from SSP_ApplicationIndividual__c WHERE SSP_Application__r.recordtype.Name=\''+'Application\'';
                                    
                String strfirstName =  req.FirstName+'%'; //req.FirstName;
                String strLastName = req.LastName+'%'; //req.LastName;
                String strMiddleInitial = req.MiddleInitial;
                date dob = req.DOB;
                String strSuffixCode = req.SuffixCode;
                String strCountyCode = req.CountyCode;
                String identifierValue = req.IdentifierValue;
                Integer identifierCase;
                if((req.IdentifierType == 'CASENUM' || req.IdentifierType == 'Case Number') && req.IdentifierValue != null) { 
                    identifierCase = Integer.valueOf(req.IdentifierValue);
                }
                
                if(String.isNotEmpty(req.FirstName) && String.isNotBlank(req.FirstName)){
                    query=query+' and SSP_Member__r.FirstName__c Like :strfirstName';
                }
                if(String.isNotEmpty(req.LastName) && String.isNotBlank(req.LastName)){
                    query=query+' and SSP_Member__r.LastName__c Like :strLastName';
                }
                if(String.isNotEmpty(req.MiddleInitial) && String.isNotBlank(req.MiddleInitial)){
                    query=query+' and SSP_Member__r.MiddleInitial__c =: strMiddleInitial';
                }
                if(req.DOB != null){
                    query=query+' and SSP_Member__r.BirthDate__c =: dob';
                }
                 if(String.isNotEmpty(req.SuffixCode) && String.isNotBlank(req.SuffixCode)){
                    query=query+' and SSP_Member__r.SuffixCode__c =: strSuffixCode';
                }
                if(String.isNotEmpty(req.CountyCode) && String.isNotBlank(req.CountyCode)){
                    query=query+' and SSP_Member__r.PhysicalCountyCode__c =: strCountyCode';
                }
                if(String.isNotEmpty(req.IdentifierType) && String.isNotBlank(req.IdentifierType) && String.isNotEmpty(req.IdentifierValue) && String.isNotBlank(req.IdentifierValue)){

                    if(req.IdentifierType == 'APPNUM' || req.IdentifierType == 'Application Number') {
                        query=query+' and SSP_Application__r.Name =: identifierValue';
                    }
                    if(req.IdentifierType == 'CASENUM' || req.IdentifierType == 'Case Number') {
                        query=query+' and SSP_Application__r.DCCaseNumber__c =: identifierCase';
                    }
                    if(req.IdentifierType == 'MAID') {
                        query=query+' and SSP_Member__r.MaidCardNumber__c =: identifierValue';
                    }
                    if(req.IdentifierType == 'SSN') {
                        query=query+' and SSP_Member__r.SSN__c =: identifierValue';
                    }
                    if(req.IdentifierType == 'INDVID' || req.IdentifierType == 'Individual Id') {
                        query=query+' and SSP_Member__r.IndividualId__c =: identifierValue';
                    }
                }
                    
                
                if(caseAccounts!=null && caseAccounts.size() > 0){
                    query = query + ' and SSP_Application__r.Account__c IN : caseAccounts';
                }
				
                query = query + ' LIMIT 200';
   
                if((caseAccounts != null && caseAccounts.size() > 0) || req.LoggedInUserRole == 'Internal') {
                    for(SSP_ApplicationIndividual__c objApplicationIndividual : Database.query(query)){
                        setSSPMembers.add(objApplicationIndividual.SSP_Member__c); 
                        lstApplicationIndividualSspMembers.add(objApplicationIndividual);               
                    }
                } 
                
                if(setSSPMembers != null && setSSPMembers.size() > 0 ) {
                    for(SSP_ApplicationIndividual__c lstHouseHoldIndividuals : [SELECT Id,IsHeadOfHousehold__c,
                                                                                SSP_Member__r.PrimaryPhoneNumber__c,
                                                                                SSP_Member__r.PrimaryPhoneExtension__c,
                                                                                SSP_Member__r.PrimaryPhoneTypeCode__c,
                                                                                SSP_Member__r.SecondaryPhoneNumber__c,
                                                                                SSP_Member__r.SecondaryPhoneExtension__c,
                                                                                SSP_Member__r.SecondaryPhoneTypeCode__c,
                                                                                SSP_Member__r.Email__c,
                                                                                SSP_Member__r.PreferredSpokenLanguageCode__c,
                                                                                SSP_Member__r.PreferredWrittenLanguageCode__c,
                                                                                SSP_Member__r.PreferredNotificationMethodCode__c,
                                                                                SSP_Member__r.IndividualId__c,
                                                                                SSP_Member__r.PhysicalAddressLine1__c,
                                                                                SSP_Member__r.PhysicalAddressLine2__c,
                                                                                SSP_Member__r.PhysicalCity__c,
                                                                                SSP_Member__r.PhysicalStateCode__c,
                                                                                SSP_Member__r.PhysicalZipCode5__c,
                                                                                SSP_Member__r.FirstName__c,
                                                                                SSP_Member__r.LastName__c,
                                                                                SSP_Member__r.BirthDate__c,
                                                                                SSP_Member__r.Age__c,
                                                                                SSP_Member__r.GenderCode__c,
                                                                                SSP_Member__r.IsDisabledToggle__c,
                                                                                SSP_Application__r.ApplicationCreationInSSP__c,
                                                                                SSP_Application__r.createddate
                                                                                FROM SSP_ApplicationIndividual__c WHERE SSP_Member__c IN :setSSPMembers ] ){
                                                                                    if(lstHouseHoldIndividuals.IsHeadOfHousehold__c == TRUE){
                                                                                        setHouseHoldMembers.add(lstHouseHoldIndividuals.SSP_Member__c);
                                                                                    }
                                                                                    lstApplicationIndividuals.add(lstHouseHoldIndividuals);     
                                                                                }
                    }
                
                    List<SSP_Relationship__c>  lstRelationship = new List<SSP_Relationship__c>();
                    if(setSSPMembers != null && setSSPMembers.size() > 0 && setHouseHoldMembers != null && setHouseHoldMembers.size() > 0) {
                        lstRelationship = [SELECT Id,RelationshipType__c,SSP_MemberRelatedTo__c,SSP_Member__c FROM SSP_Relationship__c WHERE SSP_Member__c IN:setSSPMembers AND SSP_MemberRelatedTo__c IN: setHouseHoldMembers  ];
                    }
                    List<SSP_InsuranceCoveredIndiv__c> lstinsuranceCovered = new List<SSP_InsuranceCoveredIndiv__c>();
                    if(setSSPMembers != null && setSSPMembers.size() > 0) {
                        lstinsuranceCovered = [SELECT Id,SSP_Member__c,IsTobbacoConsumerToggle__c FROM SSP_InsuranceCoveredIndiv__c WHERE SSP_Member__c IN:setSSPMembers ];
                    }
                    resp.lstApplicationIndividualSspMembers = (!lstApplicationIndividualSspMembers.isEmpty() || lstApplicationIndividualSspMembers != null ) ? lstApplicationIndividualSspMembers : resp.lstApplicationIndividualSspMembers;
                    resp.lstApplicationIndividualsHouseHold = (!lstApplicationIndividuals.isEmpty() || lstApplicationIndividuals != null  ) ? lstApplicationIndividuals : resp.lstApplicationIndividualsHouseHold;
                    resp.lstRelationship = (!lstRelationship.isEmpty() || lstRelationship != null)  ? lstRelationship : resp.lstRelationship;
                    resp.lstinsuranceCovered = (!lstinsuranceCovered.isEmpty() || lstinsuranceCovered != null)  ? lstinsuranceCovered : resp.lstinsuranceCovered;
                    resp.CustomerType = 'CA';
                    resp.DOIAgencyID = acrId ;
                	resp.StatusCode = '1';
                    resp.Status = 'SUCCESS';
                    resp.StatusDescription = 'SUCCESS';
                
            }catch(Exception ex){
                resp.StatusCode = '2';
                resp.Status = 'FAILURE';
                resp.StatusDescription = ex.getMessage();
            }
        return resp;
    }
    
   
    
       
}