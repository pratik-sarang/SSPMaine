/*********************************************************************************************************************************
* Class Name    : RE_DataTableCtrl 
* Owner         : Prashant/Sai/Pankaj
* Created Date  : 05/08/2019 
* Description   : DatasObjectName Controller class for fetching resource summary details
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*  9/15/2020    Siri           Bug#392883 - RE Security Changes pilot release
**/
public with sharing class RE_DataTableCtrl {
    /********************************************************************************************
* @author       Prashant Singh
* @date         08/05/2019
* @methodname   getLocations()
* @description  This methods is used to get the location records
* @param        void
* @return       String 
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getLocations() { 
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Boolean bSuccess = false;
        //List<String> lstRetVal = new List<String>();
        List<RE_DataTableCtrl.LocationWrapper> lstloc = new List<RE_DataTableCtrl.LocationWrapper>();
        List<Location__c> lstLocations = new List<Location__c>();            
        String sQuery;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        try{
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, RE_DataBaseQueryFields.sOrderByForReferralTest);
            
            //Map<Boolean, String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Location__c', 'Id, Name', mapQueryParameters);
            Map<Boolean, String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Location__c', RE_DatabaseQueryFields.sFieldsToQueryOnLocation, mapQueryParameters);
            
            
            
            
            
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapLocationQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                                                                                         
            switch on (switchCaseKey) {
                
                when SWITCH_SUCCESS {
                    sQuery =  mapLocationQueryResponse.get(true);
                    lstLocations = Database.query(sQuery); 
                }
                
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_DataTableCtrl', 'getLocations','Some Fields doesn\'t have the required access :: '+mapLocationQueryResponse.get(false), true);
                }
            }
            
            // lstloc.add(new RE_DataTableCtrl.LocationWrapper('All Locations', 'All'));//HardCoding to be removed   
            
            
            RE_CreateLightningServerResponse cplocresponse=RE_CreateReferralCtrl.fetchloggedInUserInfo();
            
            Contact conobj=(Contact)JSON.deserialize(String.valueOf(cplocresponse.objectData.get('records')), Contact.class);
            Id locationid=conobj.PrimaryLocation__c;
             List<Location__c> loggedinLocation=new List<Location__c>();
            
            lstloc.add(new RE_DataTableCtrl.LocationWrapper(System.Label.allLocation, 'All'));
            
            for (Location__c loc : lstLocations) {
                lstloc.add(new RE_DataTableCtrl.LocationWrapper(loc.Name, loc.Id));
                if(locationid==loc.id){
                    loggedinLocation.add(loc);
                }
            }
                
            DataTableReferralFilterWrapper filterWrapper=new DataTableReferralFilterWrapper();
            filterWrapper.lstLocationFilter=lstLocations;
            Map<String, String> mapQueryParametersresource = new Map<String, String>();
            List<Resource__c> lstResource = new List<Resource__c>();
            mapQueryParametersresource.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParametersresource.put(RE_GlobalConstants.sOrderByKey, RE_DataBaseQueryFields.sOrderByForReferralTest);
            
           
            Map<Boolean, String> mapresourceQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Resource__c', RE_DatabaseQueryFields.sFieldsToQueryOnLocation, mapQueryParametersresource);
            
            
            
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyres = (mapresourceQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                                                                                         
            switch on (switchCaseKeyres) {
                
                when SWITCH_SUCCESS {
                    sQuery =  mapresourceQueryResponse.get(true);
                    lstResource = Database.query(sQuery); 
                }
                
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_DataTableCtrl', 'getLocations','Some Fields doesn\'t have the required access :: '+mapresourceQueryResponse.get(false), true);
                }
            }
            filterWrapper.lstResourceFilter=lstResource;
            bSuccess=true;
            mapResponse.put('records', JSON.serialize(lstloc));
            mapResponse.put('filterWrapper', JSON.serialize(filterWrapper));
            mapResponse.put('loggedinLoc', JSON.serialize(loggedinLocation));
        }catch(Exception e)
        {
             errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_DataTableCtrl','getLocations',e.getMessage(),true);
            
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
* @author       Deloitte
* @date         08/05/2019
* @methodname   getData()
* @description  This methods is used to get the data for datasObjectName
* @param        String sObjectName, List<String> lstFlieds, String pageSize, String pageNumber, String recid
* @return       RE_CreateLightningServerResponse 
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getData(DataTableWrapper clsDataTable) { 
        GeneralUtility.isAuthenticatedUser();
        RE_ContactWrapper contactWrapper;
        if(clsDataTable.clientSearchDetails != null ){
           contactWrapper =  (RE_ContactWrapper) JSON.deserialize(clsDataTable.clientSearchDetails, RE_ContactWrapper.class);

        }
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Boolean bSuccess = false;        
        Integer iPageSize = Integer.valueOf(clsDataTable.pageSize);
        Integer iPageNumber = Integer.valueOf(clsDataTable.pageNumber) - 1;
        Integer iOffset = iPageSize * iPageNumber;        
        String recordId = String.escapeSingleQuotes(clsDataTable.recid);
        String sAccountId = GeneralUtility.getLoggedInAccountId();
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        String sRecordType ;
        Date userInputDate;
        Set<Id> locIdset= new Set<Id>();
        Set<Id> resIdset= new Set<Id>();
        Set<Id> sFavClientIdSet = new Set<Id>();
        Set<String> statusSet= new Set<String>();
        String filterclause='';    
        boolean isFavorites = false;
        set<Id> setUserId = new set<Id>(); 
        Map<String,String> mapInputContact= new Map<String,String>();
        try {
            
            if(clsDataTable.sObjectName=='Referral__c' && clsDataTable.referralfilterwrapper!=null){
                for(Location__c locObj : clsDataTable.referralfilterwrapper.lstLocationFilter){
                    locIdset.add(locObj.Id);
                }
                if(!locIdset.IsEmpty()){
                    filterclause=filterclause+' AND Location__c in :  locIdset ';   
                }
                if(clsDataTable.referralfilterwrapper.contactId!=null && clsDataTable.referralfilterwrapper.contactId!='' ){
                    String conid=clsDataTable.referralfilterwrapper.contactId;
                    filterclause =filterclause+' AND Contacts__c =: conid ';
                }
                
                for(Resource__c resObj : clsDataTable.referralfilterwrapper.lstResourceFilter){
                    resIdset.add(resObj.Id);
                }
                if(!resIdset.IsEmpty()){
                    filterclause=filterclause+' AND Resource__c in : resIdset ';   
                } 
                
                if(clsDataTable.referralfilterwrapper.status!=null){
                    List<Object> lstJsonParsestatus = (List<Object>)Json.deserializeUntyped(clsDataTable.referralfilterwrapper.status);
                    for(Object obj : lstJsonParsestatus)
                    {
                        Map<String,Object> mp_StrObj = (Map<string,Object>)obj;
                        statusSet.add(String.valueof(mp_StrObj.get('Id')));    
                    }  
                }
               /* Not needed as part of Bug : 341305
                if(statusSet.contains('In Progress')){
                    statusSet.add('In Progress - Org in System');
                    statusSet.add('In Progress - Org Not in System');
                } */
                if(!statusSet.IsEmpty()){
                    filterclause=filterclause+' AND Status__c in : statusSet AND CartAction__c != \'Declined\''; //[Suresh] filter declined refeeral
                } 
                if(clsDataTable.referralfilterwrapper.createddate!=null ){
                    Date datecreated=clsDataTable.referralfilterwrapper.createddate;
                    filterclause=filterclause+' AND DateOfReferral__c  =: datecreated ';   
                }  
                Integer daysopen;
                if(clsDataTable.referralfilterwrapper.dayssinceopened!=null){
                    daysopen=clsDataTable.referralfilterwrapper.dayssinceopened;                       
                }
                
                if(clsDataTable.referralfilterwrapper.lessgreaterthan!='None' && daysopen!=null && clsDataTable.referralfilterwrapper.lessgreaterthan=='Less than'){
                    filterclause=filterclause+' AND DaysSinceOpened__c  < : daysopen ';                                  
                }
                if(clsDataTable.referralfilterwrapper.lessgreaterthan!='None' && daysopen!=null && clsDataTable.referralfilterwrapper.lessgreaterthan=='Greater than'){
                    filterclause=filterclause+' AND DaysSinceOpened__c  > : daysopen ';   
                }
                
                
                if(clsDataTable.referralfilterwrapper.dafaultstatus == RE_GlobalConstants.REFERRAL_STATUS_CLOSED){
                    String sclosed=RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
                    filterclause=filterclause+' AND Status__c  !=: sclosed ';   
                }
                // run referralInbox tab clicked (making referralOutbox is false.)
                if(!clsDataTable.isReferralOutboxTabClicked && clsDataTable.referralfilterwrapper.defaultloc != null 
                    && clsDataTable.referralfilterwrapper.defaultloc!=''){
                        String locid=clsDataTable.referralfilterwrapper.defaultloc;
                        filterclause=filterclause+' AND Location__c  =: locid ';
                }
                if(clsDataTable.isReferralOutboxTabClicked){
                    String sAccId = GeneralUtility.getLoggedInAccountId();
                    filterclause=filterclause+' AND ReferredByAccountID__c  =: sAccId '; 
                }    
                //Set the organization filter
                if(clsDataTable.isReferralOutboxTabClicked && clsDataTable.referralfilterwrapper.organizationName != null && clsDataTable.referralfilterwrapper.organizationName!=''){
                    String orgName=clsDataTable.referralfilterwrapper.organizationName;
                    String searchOrgData=RE_GlobalConstants.sStartStringPercent+orgName+RE_GlobalConstants.sEndStringPercent;
                    filterclause=filterclause+' AND ReferredAccountID__r.Name LIKE '+searchOrgData;
                }
                //Set the Resource filter
                if(clsDataTable.isReferralOutboxTabClicked && clsDataTable.referralfilterwrapper.resourceName != null && clsDataTable.referralfilterwrapper.resourceName!=''){
                    
                    String resourceName=clsDataTable.referralfilterwrapper.resourceName;
                    String searchData=RE_GlobalConstants.sStartStringPercent+resourceName+RE_GlobalConstants.sEndStringPercent;
                    filterclause=filterclause+' AND Resource__r.Name LIKE '+searchData;
                }
                
                
            }  
            String sFieldsApiName = RE_DataBaseQueryFields.sQueryIdCreatedByName + String.join(clsDataTable.lstFlieds, ', ');
            String sWhereClause;
            String sOrderby ;
            if(clsDataTable.sObjectName=='Referral__c') {                
                /*if(clsDataTable.sortField=='CreatedById'){
                    clsDataTable.sortField=RE_GlobalConstants.sContactLastName;
                } */ 
                 clsDataTable.sortField = (clsDataTable.sortField=='CreatedById')?RE_GlobalConstants.sContactLastName:clsDataTable.sortField;
                sOrderby = String.isBlank(clsDataTable.sortField)?RE_DataBaseQueryFields.sCreatedDateDESC:getsortField(clsDataTable.sObjectName,clsDataTable.sortField)+' '+clsDataTable.sortDirection;
            }
            else if(clsDataTable.sObjectName=='Contact' && clsDataTable.citizenCheck!=null && !clsDataTable.citizenCheck && String.isNotBlank(clsDataTable.sortField)){
                clsDataTable.sortField=clsDataTable.sortField.contains('PrimaryLocation')?clsDataTable.sortField.replaceFirst('PrimaryLocation', 'PrimaryLocation__c'):clsDataTable.sortField;  
                clsDataTable.sortField=clsDataTable.sortField.contains('PermissionsLevel')?clsDataTable.sortField.replaceFirst('PermissionsLevel', 'PermissionsLevel__c'):clsDataTable.sortField; 
                clsDataTable.sortField=clsDataTable.sortField.contains('TrainingLevel')?clsDataTable.sortField.replaceFirst('TrainingLevel', 'TrainingLevel__c'):clsDataTable.sortField;  
                clsDataTable.sortField=clsDataTable.sortField.contains('Status')?clsDataTable.sortField.replaceFirst('Status', 'Status__c'):clsDataTable.sortField;  
                sOrderby = String.isBlank(clsDataTable.sortField)?RE_DataBaseQueryFields.sOrderByNameAsc:getsortField(clsDataTable.sObjectName,clsDataTable.sortField)+' '+clsDataTable.sortDirection;    
            }else{
                sOrderby = String.isBlank(clsDataTable.sortField)?RE_DataBaseQueryFields.sOrderByNameAsc:getsortField(clsDataTable.sObjectName,clsDataTable.sortField)+' '+clsDataTable.sortDirection;    
            }
            String sQuery;
            Date sDate = System.today();
            switch on clsDataTable.sObjectName {
                when 'Contact' { 
                    clsDataTable.sObjectName = RE_GlobalConstants.strSobjectName;
                    //if (clsDataTable.citizenCheck ){
                    RE_GlobalConstants.SWITCH_CONSTANTS isCitizenCheck = (clsDataTable.citizenCheck)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                    switch on (isCitizenCheck){
                        when SWITCH_SUCCESS {
                            //if (clsDataTable.allClientsCheck){
                                RE_GlobalConstants.SWITCH_CONSTANTS allClientsCheck = (clsDataTable.allClientsCheck)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                                switch on (allClientsCheck){
                                when SWITCH_SUCCESS {
                                sRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.strCitizenRecordTypeName, clsDataTable.sObjectName).Name;
                                    if(contactWrapper != null ){
                                        return RE_ClientsHelper.getAllClientDetails(contactWrapper,clsDataTable);
                                    }else{
                                        // Start Commented as per ONEVIEW-1361-Payal(Client whose user are not enabled do not show up in All Client)
                                
                               /*String sUserWhereClause = RE_DataBaseQueryFields.sUserWhereClauseForAllCients;
                                Map<String, String> mapUserQueryParameters = new Map<String, String>();
                                mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
                                String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User','ContactId', mapUserQueryParameters);            
                                List<User> lstUserActiveCommunity = Database.query(userQuery); 
                                
                                //List<User> lstUserActiveCommunity = [Select Id,ContactId FROM User WHERE Profile.Name = 'RE Citizen Profile' AND isActive = true];
                                
                                for(user usr:lstUserActiveCommunity){
                                    setUserId.add(usr.ContactId);
                                }
                                sWhereClause = RE_DataBaseQueryFields.sWhereClauseRecNameHasOptedOutOfAccount;*/
                            // END Commented as per ONEVIEW-1361-Payal 

                                //Added by Payal(ONEVIEW-1361)
                                        sWhereClause = RE_DataBaseQueryFields.sWhereClauseRecNameHasOptedOutOfAccountNew;
                                    }
                                }when SWITCH_FAILURE{
                                    clsDataTable.sObjectName = RE_GlobalConstants.consentobjectName;
                                    sFieldsApiName = RE_DataBaseQueryFields.sWhereClauseDataTableAPIFields;
                                    sOrderby= String.isBlank(clsDataTable.sortField) ? RE_DataBaseQueryFields.sOrderByNameAsc: RE_GlobalConstants.sClientRelationshipName+'.'+clsDataTable.sortField+' '+clsDataTable.sortDirection;
                                    //RE_Release 1.1 – Defect 358970- Payal Dubela– Remove search option on "Profile Access Clients" tab on client search screen
                            /*if(contactWrapper !=null){
                                if(contactWrapper.FirstName == Null){
                                    userInputDate = contactWrapper.birthDate;
                                    sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_5_ContactWrapperDataTable+contactWrapper.LastName+'%\' AND Client__r.BirthDate =: userInputDate';
                                }else if(contactWrapper.LastName == Null){
                                    userInputDate = contactWrapper.birthDate;
                                    sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_6_ContactWrapperDataTable+contactWrapper.FirstName+'%\' AND Client__r.BirthDate =: userInputDate';
                                }else if(contactWrapper.birthDate == Null){
                                    sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_6_ContactWrapperDataTable+contactWrapper.FirstName+'%\' AND client__r.LastName LIKE \'%'+contactWrapper.LastName+'%\'';
                                }else{
                                    userInputDate = contactWrapper.birthDate;
                                    sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_8_ContactWrapperDataTable+contactWrapper.FirstName+'%\' AND client__r.LastName LIKE \'%'+contactWrapper.LastName+'%\') AND Client__r.BirthDate =: userInputDate';
                                }
                            }else{*/
                                    sWhereClause = RE_DataBaseQueryFields.sWhereClauseOrgAndStatus;
                                   // }
                                }
                            }                           
                         }                      
                        when SWITCH_FAILURE {
                            sFieldsApiName += RE_DataBaseQueryFields.sPrimaryLocationNameAddition;
                            sFieldsApiName=sFieldsApiName.replaceFirst('PrimaryLocation', 'PrimaryLocation__c');  
                            sFieldsApiName=sFieldsApiName.replaceFirst('PermissionsLevel', 'PermissionsLevel__c'); 
                            sFieldsApiName=sFieldsApiName.replaceFirst('TrainingLevel', 'TrainingLevel__c');  
                            sFieldsApiName=sFieldsApiName.replaceFirst('Status', 'Status__c');       
                            //RE Security Changes - Payal Dubela 
                            Id nonCitizenRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Contact',RE_GlobalConstants.strNonCitizenContactDevName);
                            String cpAdminRole=RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
                            String cpStaffRole=RE_GlobalConstants.COMMUNITY_PARTNER_STAFF;
                            String agencyAdminRole=RE_GlobalConstants.CASE_WORKER_SUPERVISOR; 
                            String agencyStaffRole=RE_GlobalConstants.CASE_WORKER;
                            if (clsDataTable.recid != 'All') {
                                sWhereClause = RE_DataBaseQueryFields.sWhereClausePriLocationRecordType;
                            }else{
                                sWhereClause = RE_DataBaseQueryFields.sWhereClauseRecTypeNoteqLocRecType;
                            }
                            mapInputContact.put('nonCitizenRecordTypeId',nonCitizenRecordTypeId);
                            mapInputContact.put('cpAdminRole',cpAdminRole);
                            mapInputContact.put('cpStaffRole',cpStaffRole);
                            mapInputContact.put('agencyAdminRole',agencyAdminRole);
                            mapInputContact.put('agencyStaffRole',agencyStaffRole);
                            mapInputContact.put('recordId',recordId);
                            mapInputContact.put('sAccountId',sAccountId);
                        }
                    }
                }
                when 'Resource__c' {
                    clsDataTable.sObjectName = RE_GlobalConstants.resourceobjectName;
                    if(String.isBlank(clsDataTable.sortField)){
                        sOrderby=RE_DataBaseQueryFields.sOrderbyStatusAsc;
                    }
                    sWhereClause = RE_DataBaseQueryFields.sWhereClauseOrganizationToAccount;
                }
                when 'Referral__c' {
                    clsDataTable.sObjectName = RE_GlobalConstants.referralobjectName;
                    sFieldsApiName += RE_DataBaseQueryFields.sAPINamesLocCont;
                    if (clsDataTable.recid != 'All') {
                        sWhereClause = RE_DataBaseQueryFields.sWhereClauseLocInRecordId;
                    }else{
                        /*if(filterclause!=null && filterclause!=''){
                            sWhereClause = RE_DataBaseQueryFields.allfilter +filterclause;  

                        }else{
                            sWhereClause = RE_DataBaseQueryFields.allfilter+filterclause; 
                        }*/
                      sWhereClause = (filterclause!=null && filterclause!='')?RE_DataBaseQueryFields.allfilter +filterclause:RE_DataBaseQueryFields.allfilter+filterclause;
                    }
                }
                when 'Favorite__c' {//Nandita: 03/24/2020: added logic to get details for Favorite Client :357475
                     sFavClientIdSet = GeneralUtility.getFavoriteClientIds();
                     clsDataTable.sObjectName = RE_GlobalConstants.strSobjectName;
                     sWhereClause = RE_DataBaseQueryFields.sWhereClauseonMyClients;
                     isFavorites = true;
                }
            }
            Map<String, String> mapQueryParameters = new Map<String, String>();
            if (sWhereClause != null){
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            }
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, String.valueof(iPageSize));
            mapQueryParameters.put(RE_GlobalConstants.sOffset, String.valueof(iOffset));
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderby);
               
            Map<Boolean, String> mapResponsesObjectName = RE_DataAccessChecker.getFieldsAccessibility(clsDataTable.sObjectName, sFieldsApiName, mapQueryParameters);

            if (mapResponsesObjectName.get(true) != null) {
                sQuery = mapResponsesObjectName.get(true);                    
            } else {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_DataTableCtrl','getData','Some Fields doesnt have the required access : '+mapResponsesObjectName.get(false),true);
            }
            
            if(clsDataTable.sObjectName.EqualsIgnoreCase('Resource__c')){
                sQuery = sQuery.replaceFirst('SdohDomain__c', 'toLabel(SdohDomain__c)'); // defect Bug 362354:Domain Sorting issue on Resource Summary Screen
            }
           if(clsDataTable.sObjectName.EqualsIgnoreCase('Referral__c')){
                sQuery = sQuery.replaceFirst('Status__c', 'toLabel(Status__c)');
            } 
            if (sQuery != null) {    

                List<Object> lstRecords = new List<Object>();
              
                if(clsDataTable.sObjectName == 'Consent__c' && clsDataTable.citizenCheck == true){
                    Map<String, String> mapInputs= new Map<String, String>();
                    mapInputs.put('sQuery',sQuery);
                    mapInputs.put('userInputDate',String.valueOf(userInputDate));
                    
                    lstRecords = RE_SharingByPassCtrl.getConsentRecords(mapInputs, null);
                    List<RE_ContactWrapper> lstContactRecords = new List<RE_ContactWrapper>() ;
                    for(Consent__c obj : (List<Consent__c>)lstRecords){
                        RE_ContactWrapper wrapContact= new RE_ContactWrapper(obj);
                             lstContactRecords.add(wrapContact);
                    }
                    mapResponse.put('records', lstContactRecords);
                }else{
                    // Run when referrral inbox tab is clicked
                    if(clsDataTable.sObjectName== RE_GlobalConstants.strSobjectName 
                       && !clsDataTable.citizenCheck && !isFavorites){
                        lstRecords = RE_SharingByPassCtrl.getContactRecords(sQuery,mapInputContact);
                        Map<Id,AccountContactRelation> acrMap=RE_SharingByPassCtrl.getACR((List<Contact>)lstRecords,sAccountId);
                        List<RE_UserWrapper> userWrapper= new List<RE_UserWrapper>();
                        for(Contact obj : (List<Contact>)lstRecords){
                            RE_UserWrapper wrapContact= new RE_UserWrapper(obj);
                            if(acrMap!=null && acrMap.containsKey(obj.Id) && (obj.Status__c==RE_GlobalConstants.INACTIVE
                               || acrMap.get(obj.Id).isActive==false)){
                                wrapContact.Status=RE_GlobalConstants.INACTIVE;
                            }
                            userWrapper.add(wrapContact);
                        }
                        mapResponse.put('records', userWrapper);
                    }
                    else if(!clsDataTable.isReferralOutboxTabClicked){
                        lstRecords = Database.query(sQuery);
                        mapResponse.put('records', lstRecords);
                    }
                    //Run when referrral outbox tab is clicked
                    else{
                        Map<String, String> mapInputs = new Map<String, String>();
                        mapInputs.put('sQuery',sQuery);
                        mapInputs.put('sclosed',RE_GlobalConstants.REFERRAL_STATUS_CLOSED);
                        mapInputs.put('sAccId',GeneralUtility.getLoggedInAccountId());
                        mapInputs.put('conid',clsDataTable.referralfilterwrapper.contactId);
                        if(clsDataTable.referralfilterwrapper.dayssinceopened!=null){
                            mapInputs.put('daysopen',String.valueOf(clsDataTable.referralfilterwrapper.dayssinceopened));
                        }
                        if(clsDataTable.referralfilterwrapper.createddate!=null){
                            mapInputs.put('datecreated',String.valueOf(clsDataTable.referralfilterwrapper.createddate));
                        }
                        lstRecords=RE_SharingByPassCtrl.getReferralOrganizationDetails(mapInputs,statusSet,resIdset);
                        mapResponse.put('records', lstRecords);
                    } 
                   
                }
                bSuccess = true;
            }
        } catch (Exception e) { errorMap.put('error', e.getMessage()+e.getLineNumber());
                               LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_DataTableCtrl','getData',e.getMessage()+' '+e.getStackTraceString() + e.getLineNumber(),true);
                              }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    } 
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse getAssisterData(DataTableWrapper clsDataTable) { 
        GeneralUtility.isAuthenticatedUser();
        RE_ContactWrapper contactWrapper;
        //RE_Release 1.1 – 360553:No records getting displayed on the Profile Access Clients screen for Assister- Payal Dubela  
        Set<Id> sFavClientIdSet = new Set<Id>();
        if(clsDataTable.clientSearchDetails != null ){
            contactWrapper =  (RE_ContactWrapper) JSON.deserialize(clsDataTable.clientSearchDetails, RE_ContactWrapper.class);
            
        }
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Boolean bSuccess = false;        
        Integer iPageSize = Integer.valueOf(clsDataTable.pageSize);
        Integer iPageNumber = Integer.valueOf(clsDataTable.pageNumber) - 1;
        Integer iOffset = iPageSize * iPageNumber;        
        String recordId = String.escapeSingleQuotes(clsDataTable.recid);
        String sAccountId = GeneralUtility.getLoggedInAccountId();
        Id contactId = GeneralUtility.getLoggedInUserContactId();
        Date userInputDate;
        set<Id> setUserId = new set<Id>(); 
        try {            
            String sFieldsApiName = RE_DataBaseQueryFields.sQueryIdCreatedByName + String.join(clsDataTable.lstFlieds, ', ');
            String sOrderby = String.isBlank(clsDataTable.sortField)?RE_DataBaseQueryFields.sOrderByNameAsc:getsortField(clsDataTable.sObjectName,clsDataTable.sortField)+' '+clsDataTable.sortDirection;
            String sQuery;
            Date sDate = System.today();
            //RE Security Changes - Payal dubela
            String sRecordType; 
            String sNonCitizenRecordType;
            String citizenRole=RE_GlobalConstants.sPercentage+RE_GlobalConstants.strCitizenAppRole+RE_GlobalConstants.sPercentage;
             //RE_Release 1.1 – 360553:No records getting displayed on the Profile Access Clients screen for Assister- Payal Dubela  
            if(clsDataTable.sObjectName=='Contact'){
                sRecordType= GeneralUtility.fetchRecordType(RE_GlobalConstants.strCitizenRecordTypeName, clsDataTable.sObjectName).Name;
                sNonCitizenRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.strNonCitizenContactDevName, clsDataTable.sObjectName).Name;
            }
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_10_ContactWrapperDataTable;
            Map<String, String> mapContactQueryParameters = new Map<String, String>();
            mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapContactQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderby);
            
            Set<Id> setContactIds = new Set<Id>();
            Map<Boolean, String> mapContactObjectResponse = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsApiName, mapContactQueryParameters);
            if (mapContactObjectResponse.get(true) != null) {
                sQuery = mapContactObjectResponse.get(true);  
                List<Contact> lstContactRecords = Database.query(sQuery); 
                for(Contact objCon : lstContactRecords){
                    setContactIds.add(objCon.Id);
                }
            }
            switch on clsDataTable.sObjectName {
                when 'Contact' { 
                    clsDataTable.sObjectName = RE_GlobalConstants.strSobjectName;
                    if (clsDataTable.allClientsCheck){
                        sRecordType = GeneralUtility.fetchRecordType(RE_GlobalConstants.strCitizenRecordTypeName, clsDataTable.sObjectName).Name;
                        if(contactWrapper != null ){
                             return RE_ClientsHelper.getAllClientDetails(contactWrapper,clsDataTable);
                                                         /*if(contactWrapper.FirstName == Null){
                                userInputDate = contactWrapper.birthDate;
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_ContactWrapperDataTable+contactWrapper.LastName+'%\' AND BirthDate =: userInputDate';  
                            }else if(contactWrapper.LastName == Null){
                                userInputDate = contactWrapper.birthDate;
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_2_ContactWrapperDataTable+contactWrapper.FirstName+'%\' AND BirthDate =: userInputDate';  
                            }else if(contactWrapper.birthDate == Null){
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_2_ContactWrapperDataTable+contactWrapper.FirstName+'%\' AND LastName LIKE \'%'+contactWrapper.LastName+'%\'';
                            }else{
                                userInputDate = contactWrapper.birthDate;
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_3_ContactWrapperDataTable+contactWrapper.FirstName+'%\' OR LastName LIKE \'%'+contactWrapper.LastName+'%\') AND BirthDate =: userInputDate';
                            }*/
                        }else{
                            /*String sUserWhereClause = RE_DataBaseQueryFields.sUserWhereClauseForAllCients;
                                
                                Map<String, String> mapUserQueryParameters = new Map<String, String>();
                                mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
                                String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User','ContactId', mapUserQueryParameters);            
                                List<User> lstUserActiveCommunity = Database.query(userQuery); 
                                
                                
                                
                                for(user usr:lstUserActiveCommunity){
                                    setUserId.add(usr.ContactId);
                                }*/
                                sWhereClause = RE_DataBaseQueryFields.sWhereClauseRecNameHasOptedOutOfAccountNew;
                        }
                    }else{
                        clsDataTable.sObjectName = RE_GlobalConstants.consentobjectName;
                        // userInputDate = contactWrapper.birthDate;
                        
                        sFieldsApiName = RE_DataBaseQueryFields.sWhereClauseDataTableAPIFields;
                        sOrderby= String.isBlank(clsDataTable.sortField) ? RE_DataBaseQueryFields.sOrderByNameAsc: RE_GlobalConstants.sClientRelationshipName+'.'+clsDataTable.sortField+' '+clsDataTable.sortDirection;
                        if(contactWrapper != null){

                            if(contactWrapper.FirstName == Null){
                                userInputDate = contactWrapper.birthDate;
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_5_ContactWrapperDataTableAssister+contactWrapper.LastName+'%\' AND Client__r.BirthDate =: userInputDate';
                            }else if(contactWrapper.LastName == Null){
                                userInputDate = contactWrapper.birthDate;
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_6_ContactWrapperDataTableAssister+contactWrapper.FirstName+'%\' AND Client__r.BirthDate =: userInputDate';
                            }else if(contactWrapper.birthDate == Null){
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_6_ContactWrapperDataTableAssister+contactWrapper.FirstName+'%\' AND client__r.LastName LIKE \'%'+contactWrapper.LastName+'%\'';
                            }else{
                                sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_8_ContactWrapperDataTableAssister+contactWrapper.FirstName+'%\' OR client__r.LastName LIKE \'%'+contactWrapper.LastName+'%\') AND Client__r.BirthDate =: userInputDate';
                            }
                        }else{
                            sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_9_ContactWrapperDataTable;
                        }
                    }  
                }
                 //RE_Release 1.1 – 360553:No records getting displayed on the Profile Access Clients screen for Assister- Payal Dubela  
                when 'Favorite__c' { 
                    sFavClientIdSet = GeneralUtility.getFavoriteClientIds();
                    clsDataTable.sObjectName = RE_GlobalConstants.strSobjectName;
                    sWhereClause = RE_DataBaseQueryFields.sWhereClauseonMyClients;
                }
            }
            Map<String, String> mapQueryParameters = new Map<String, String>();
            if (sWhereClause != null){
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            }
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, String.valueof(iPageSize));
            mapQueryParameters.put(RE_GlobalConstants.sOffset, String.valueof(iOffset));
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderby);
            
            Map<Boolean, String> mapResponsesObjectName = RE_DataAccessChecker.getFieldsAccessibility(clsDataTable.sObjectName, sFieldsApiName, mapQueryParameters);
            if (mapResponsesObjectName.get(true) != null) {
                sQuery = mapResponsesObjectName.get(true);                    
            } else {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_DataTableCtrl','getData','Some Fields doesnt have the required access : '+mapResponsesObjectName.get(false),true);
            }
            if (sQuery != null) {    
                List<Object> lstRecords = new List<Object>();
                if(clsDataTable.sObjectName == 'Consent__c' && clsDataTable.citizenCheck == true){
                    Map<String, String> mapInputs= new Map<String, String>();
                    mapInputs.put('sQuery',sQuery);
                    mapInputs.put('userInputDate',String.valueOf(userInputDate));
                    mapInputs.put('contactId',contactId);
                    lstRecords = RE_SharingByPassCtrl.getConsentRecords(mapInputs, setContactIds);
                    List<RE_ContactWrapper> lstContactRecords = new List<RE_ContactWrapper>() ;
                    for(Consent__c obj : (List<Consent__c>)lstRecords){
                        RE_ContactWrapper wrapContact= new RE_ContactWrapper(obj);
                        lstContactRecords.add(wrapContact);
                    }
                    mapResponse.put('records', lstContactRecords);
                }else{
                    lstRecords = Database.query(sQuery); 
                    mapResponse.put('records', lstRecords);
                }
                bSuccess = true;
            }
        } catch (Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_DataTableCtrl','getData',e.getMessage()+' '+e.getStackTraceString() + e.getLineNumber(),true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    } 
    private static String getsortField(String sobjname,String sortField){
        if(RE_GlobalConstants.consentobjectName==sobjname){
            sobjname=RE_GlobalConstants.strSobjectName;
        }
        //RE_Release 1.1 – 365008:Sorting issue on My Clients Screen
        if(RE_GlobalConstants.sFavoriteObjectName==sobjname){
            sobjname=RE_GlobalConstants.strSobjectName;
        }
        String dataType;
        String relationshipName = '';
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(sobjname).getDescribe();
        Map<String, Schema.SObjectField> mfields = objectDescribe.fields.getMap();                
        if(sobjname=='Referral__c' && sortField=='Contacts__r.LastName'){
            relationshipName = sortField;
        }
        else{
            dataType = String.valueOf(mfields.get(sortField).getDescribe().getType());                
            if(dataType == 'REFERENCE') {
                relationshipName = mfields.get(sortField).getDescribe().getRelationshipName()+'.Name';
            } else{
                relationshipName= sortField; 
            }
        }        
        return relationshipName;
    }
        /********************************************************************************************
    * @author       Deloitte
    * @date         07/09/2019
    * @methodname   getUserRole()
    * @description  This methods is used to get the user role
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getUserRole() { 
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Boolean bSuccess = false;
        Boolean bIsAdmin =  false;
        Boolean bIsAssister = false;
        Boolean bIsCPUser = false;
        Boolean bIsAgencyUser = false;
        try{
            List<PermissionSetAssignment> lstPermissionSet = GeneralUtility.geLoggedInUserPermissionSets();
            String sRole = GeneralUtility.getLoggedInUserSelectedRole();
            for(PermissionSetAssignment pmset : lstPermissionSet){
                if(pmset.PermissionSet.Name==RE_GlobalConstants.ADMIN_PERMISSIONSET_NAME){
                    bIsAdmin=true;
                }
                // commented as part of ONEVIEW-1531
                /*if(pmset.PermissionSet.Name==RE_GlobalConstants.ASSISTER_PERMISSIONSET_NAME){
                    bIsAssister=true;
                }*/
            }
            if(sRole == RE_GlobalConstants.RE_ASSISTER_ROLE){
                bIsAssister=true;
            }
            if(sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || sRole == RE_GlobalConstants.CASE_WORKER){
                bIsAgencyUser=true;
            }
            if(sRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || sRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF){
                bIsCPUser=true;
            }
            bSuccess = true;
            mapResponse.put('isAdmin', bIsAdmin);
            mapResponse.put('isAssister', bIsAssister);
            mapResponse.put('isAgencyUser', bIsAgencyUser);
            mapResponse.put('isCPUser', bIsCPUser);
        }catch(Exception e){ 
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_DataTableCtrl.class.getName(),'getUserRole',e.getMessage(), true);                
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    } 
    
    
      /**************************************************************************************
    * @author       Arun Garg
    * @date         16/12/2019
    * @methodname   checkUserForContact
    * @description  This methods is used to check contact for user
    * @param        String strContactId
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/

    @AuraEnabled
    public static RE_CreateLightningServerResponse checkUserForContact(String strContactId){
       
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sQuery;
        Boolean bSuccess = false;
        Map<Id,AccountContactRelation> acrMap=new Map<Id,AccountContactRelation>();
        String sAccountId=GeneralUtility.getLoggedInAccountId();
        try{ 
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsOnContact;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnContactForUser;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strSobjectUser, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    List<User> listUser = Database.query(sQuery);  
                    mapResponse.put('user',listUser.size());
                    bSuccess = true;
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchClientDetails','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            Contact objContact = new Contact();
            objContact.Id=strContactId;
            acrMap=RE_SharingByPassCtrl.getACR(new List<Contact>{objContact},sAccountId);
            if(acrMap!=null && acrMap.values().size()>0 && !(acrMap.values()[0]).isActive){
                mapResponse.put('isActive',false);
            }else{
                mapResponse.put('isActive',true);
            }
            
        }
        catch(Exception e){
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_DataTableCtrl.class.getName(),'checkUserForContact',e.getMessage(), true);                
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }  
    
     @AuraEnabled
    public static  RE_CreateLightningServerResponse getPickListValues(String strObjectName, String strLstFields){
        
        String objectName = String.escapeSingleQuotes(strObjectName);
        String lstFields = String.escapeSingleQuotes(strLstFields);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try {
                    Map<String, Map<String, String>> values = GeneralUtility.fetchFieldsPicklistValueAPIName(objectName, lstFields);
                    bSuccess = true;
                    mapResponse.put('picklistvalues', values);
                } catch(Exception e) {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl','getPickListValues', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse createContactForIEESData(String IEESData){
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse response=RE_ClientDetailsCtrl.createContactForIEESData(IEESData);
        return response;
    }
    
    //Wrapper for location
    public class LocationWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String value {get;set;}
        //Create and set two variables label and value as required by the lightning:checkboxGroup
        public LocationWrapper(String label, String value){
            this.label = label;
            this.value = value; 
        }
    }    
    public class DataTableWrapper{
        @AuraEnabled public String sObjectName{get; set;}
        @AuraEnabled public List<String> lstFlieds{get; set;}
        @AuraEnabled public String pageSize{get; set;}
        @AuraEnabled public String pageNumber{get; set;}
        @AuraEnabled public String recid{get; set;}
        @AuraEnabled public Boolean citizenCheck{get; set;}
        @AuraEnabled public Boolean allClientsCheck{get; set;}
        @AuraEnabled public String clientSearchDetails{get; set;}
        @AuraEnabled public String sortField{get; set;}
        @AuraEnabled public String sortDirection{get; set;}
        @AuraEnabled public Boolean isReferralOutboxTabClicked{get; set;}
        @AuraEnabled public DataTableReferralFilterWrapper referralfilterwrapper{get; set;}
    }
    
    
    //Wrapper class to fetch the datatable filters     
    public class DataTableReferralFilterWrapper{
        @AuraEnabled public String contactId{get; set;}
        @AuraEnabled public Date createddate{get; set;}
        @AuraEnabled public Integer dayssinceopened{get; set;}
        @AuraEnabled public String lessgreaterthan{get; set;}
        @AuraEnabled public String dafaultstatus{get; set;}
        @AuraEnabled public String defaultloc{get; set;}
        @AuraEnabled public String status{get; set;}
        @AuraEnabled public String organizationName{get; set;}
        @AuraEnabled public String resourceName{get; set;}
        @AuraEnabled public List<Location__c> lstLocationFilter{get; set;}
        @AuraEnabled public List<Resource__c> lstResourceFilter{get; set;}
    }
}