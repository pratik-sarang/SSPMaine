/**
* Class Name    : RE_ClientsHelper
* Owner         : DELOITTE
* Created Date  : 10/22/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  10/22/2019  Payal Dubela       Initial Version
* */
public with sharing class RE_ClientsHelper {
    
    public static RE_CreateLightningServerResponse getAllClientDetails(RE_ContactWrapper contactWrapper,RE_DataTableCtrl.DataTableWrapper clsDataTable) {
        List<Contact> conList=new List<Contact>();
        List<Contact_Mapping__c> mappingList= new List<Contact_Mapping__c>();
        set<Decimal> sIEESIds = new Set<Decimal>();
        List<DataTableWrapper> wrapperList= new List<DataTableWrapper>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Boolean bSuccess = false;  
        DataTableWrapper wrapper;   
        RE_ClientSearchResponse wrapIEESResponseData;
        Date userInputDate = contactWrapper.birthDate;
        //RE_ClientSearchReqWrapper.RequestData requestWrap= new RE_ClientSearchReqWrapper.RequestData(contactWrapper.FirstName,contactWrapper.LastName,String.valueof(userInputDate));
        RE_ClientSearchReqWrapper.RequestData requestWrap;
        if(contactWrapper.birthDate != null && contactWrapper.FirstName != null && contactWrapper.LastName != null) 
        {
            requestWrap= new RE_ClientSearchReqWrapper.RequestData(contactWrapper.FirstName,contactWrapper.LastName,String.valueof(userInputDate), 'Default');
        }
        else if(contactWrapper.Individualid != null && contactWrapper.Individualid != '')
        {
            requestWrap= new RE_ClientSearchReqWrapper.RequestData(contactWrapper.Individualid, 'Individualid');
        }
        else if(contactWrapper.SSN != null && contactWrapper.SSN != '')
        {
            requestWrap= new RE_ClientSearchReqWrapper.RequestData(contactWrapper.SSN, 'SSN');
        }
        else if(contactWrapper.CaseNumber != null && contactWrapper.CaseNumber != '')
        {
            requestWrap= new RE_ClientSearchReqWrapper.RequestData(contactWrapper.CaseNumber, 'CaseNumber');
        }
        Map<String,Object> request=new Map<String,Object>();
        request.put('indSearchRequest',requestWrap);
        
        try{
            //RE Search
            conList=getClients(contactWrapper,clsDataTable);
            if(!conList.isEmpty()){
                mappingList=getContactMappings(conList);
                for(Contact_Mapping__c con:mappingList){
                    sIEESIds.add(con.IEES_Id__c);
                }
            }
            //IEES Search
            Map<String,Object> mapInputData = new Map<String,Object>();
            mapInputData.put('request',request);
            REIntegrationCodes__c oIntCodes = REIntegrationCodes__c.getValues('SuccessCode');
            
            Map<String, Object> IEESReponse=RE_ServiceHandler.handleExecutionResults('GetClients',mapInputData);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyieesdata = (IEESReponse.containskey('ClientSearch'))? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyieesdata) {
             when SWITCH_SUCCESS {  
                wrapIEESResponseData = (RE_ClientSearchResponse)IEESReponse.get('ClientSearch');
                RE_GlobalConstants.SWITCH_CONSTANTS switchErrorData = (wrapIEESResponseData.indSearchResponse!=null && wrapIEESResponseData.indSearchResponse.errorData!=null && wrapIEESResponseData.indSearchResponse.errorData.errorCode!=oIntCodes.Code__c) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS  ;                                                                                            
                switch on (switchErrorData) {
                 when SWITCH_SUCCESS {
                    RE_GlobalConstants.SWITCH_CONSTANTS switchWrpIEES = (wrapIEESResponseData != null && wrapIEESResponseData.indSearchResponse.matchResult!=0)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                     switch on (switchWrpIEES){
                        when SWITCH_SUCCESS {
                        //if(wrapIEESResponseData != null && wrapIEESResponseData.indSearchResponse.matchResult!=0){
                        for(RE_ClientSearchResponse.ClientData  client: wrapIEESResponseData.indSearchResponse.memberData){
                            if((sIEESIds.isEmpty()|| (!sIEESIds.isEmpty()
                                                     && !sIEESIds.contains(Decimal.valueof(client.individualId))))){
                                                         
                            wrapper =new  DataTableWrapper(client);

                            if(calculateAge(wrapper.BirthDate)>=18){
                                wrapperList.add(wrapper);
                            }                    
                          }
                        }
                    }
                 }
                 }
                 when SWITCH_FAILURE { 
                    REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('ClientSearch');
                    String sEndpoint = oIntEndpoints.Endpoint_URI__c;
                    String sHttpMethod = oIntEndpoints.Http_Method_Type__c;
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,sEndpoint,'RE_ClientsHelper','execute','Callout to Client Search Failed',sHttpMethod,JSON.serialize(request),wrapIEESResponseData.indSearchResponse.errorData.errorCode,wrapIEESResponseData.indSearchResponse.errorData.errorDescription,0,false);
                 }
                }
              }
            }
                    
            for(Contact con: conList){
               if(con.OptOutInfoSharing__c==false){
                    wrapper =new  DataTableWrapper(con);
                    wrapperList.add(wrapper);
               }  
            }
            bSuccess=true;
            mapResponse.put('records', wrapperList);
        }catch (Exception e) {
           
            errorMap.put('error', e.getMessage());
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
        
    }
    
    public static List<Contact> getClients(RE_ContactWrapper contactWrapper,RE_DataTableCtrl.DataTableWrapper clsDataTable){
        String sRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.strCitizenRecordTypeName, clsDataTable.sObjectName).Name;
        //RE Security Changes -- Payal Dubela
        String sNonCitizenRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.strNonCitizenContactDevName, clsDataTable.sObjectName).Name;
        Map<String, String> mapInputs=new Map<String, String>();
        Date userInputDate = contactWrapper.birthDate;
        String sWhereClause = RE_DataBaseQueryFields.sWhereClauseonClientSearch+ ' (FirstName LIKE \'%'+contactWrapper.FirstName+'%\' AND LastName LIKE \'%'+contactWrapper.LastName+'%\') ';
        String sFieldsApiName = RE_DataBaseQueryFields.sQueryIdCreatedByName +RE_DataBaseQueryFields.sFieldsonClientSearch+ String.join(clsDataTable.lstFlieds, ', ');
        Map<String, String> mapQueryParameters = new Map<String, String>();
        List<Contact> lstRecords=new List<Contact>();
        String sQuery;
        if (sWhereClause != null){
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        }
        
        Map<Boolean, String> mapResponsesObjectName = RE_DataAccessChecker.getFieldsAccessibility(clsDataTable.sObjectName, sFieldsApiName, mapQueryParameters);
        
        if (mapResponsesObjectName.get(true) != null) {
            sQuery = mapResponsesObjectName.get(true);                    
        } else {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_DataTableCtrl','getData','Some Fields doesnt have the required access : '+mapResponsesObjectName.get(false),true);
        }
        mapInputs.put('sNonCitizenRecordType',sNonCitizenRecordType);
        if (sQuery != null) {
            lstRecords=RE_SharingByPassCtrl.getClients(sQuery,userInputDate,sRecordType,mapInputs);
        }
        return lstRecords;
    }
    
    public static List<Contact_Mapping__c> getContactMappings(List<Contact> conList){
        String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_CONTACT_MAPPING;
        String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnContactMapping;
        String sOrderBy = RE_DataBaseQueryFields.sOrderByOnContactMapping;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        List<Contact_Mapping__c> lstRecords=new List<Contact_Mapping__c>();
        String sQuery;
        if (sWhereClause != null){
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderBy);
        }
        
        Map<Boolean, String> mapResponsesObjectName = RE_DataAccessChecker.getFieldsAccessibility('Contact_Mapping__c', sFieldsApiName, mapQueryParameters);
        
        if (mapResponsesObjectName.get(true) != null) {
            sQuery = mapResponsesObjectName.get(true);                    
        } else {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ClientsHelper','getData','Some Fields doesnt have the required access : '+mapResponsesObjectName.get(false),true);
        }
        Map<String, String> mapInputs= new Map<String,String>();
        mapInputs.put('sQuery',sQuery);
        if (sQuery != null) {
            lstRecords = RE_SharingByPassCtrl.getContactMappings(mapInputs,conList);
        }
        
        return lstRecords; 
    }
    
    public class DataTableWrapper{
        @AuraEnabled  public String Id;
        @AuraEnabled  public String FirstName;
        @AuraEnabled  public String LastName;
        @AuraEnabled  public String Email;
        @AuraEnabled  public String Phone;
        @AuraEnabled  public Date BirthDate;
        @AuraEnabled  public String IEESId;
        @AuraEnabled  public String PreferredContactMethodCode;
        @AuraEnabled  public String Gender;
        
        public DataTableWrapper(RE_ClientSearchResponse.ClientData client){
            this.FirstName=client.firstName;
            this.LastName=client.lastName;
            this.Email=client.email;
            this.Phone=client.phoneNumber;
            this.BirthDate=client.dob;
            this.IEESId=String.valueof(client.individualId);
            this.PreferredContactMethodCode=client.preferredContactMethodCode;
            this.Gender=client.gender=='M'?'Male':(client.gender=='F'?'Female':'Other');
        }
        public DataTableWrapper(Contact con){
            this.FirstName=con.FirstName;
            this.LastName=con.LastName;
            this.Email=con.Email;
            this.Phone=con.Phone;
            this.BirthDate=con.Birthdate;
            this.Id=con.Id;
            this.PreferredContactMethodCode=con.PreferredCommunicationMethod__c;
            this.Gender=con.Gender__c;
        }
        public DataTableWrapper(){}
        
    }

    public static Integer calculateAge (Date birthdate){
        Integer days = birthdate.daysBetween(Date.Today());
        Integer age = Integer.valueOf(days/365);
        return age;
    }
    
}