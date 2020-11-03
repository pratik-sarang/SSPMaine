/**
* Class Name    : RE_PrivacySettingCtrl
* Owner         : DELOITTE
* Created Date  : 06/20/2019
* Description   : Fetching the Consent Object Record Based on the Consent level 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/20/2019  SRIKANTH       Initial Version
* 
**/
public with sharing class RE_PrivacySettingCtrl {
    
    /*********************************************************************************************************************************
* @author       SRIKANTH
* @date         06/20/2019
* @methodname   fetchConsentDetails()
* @description  
* @param        NA
* @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchConsentDetails(){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        
        Id loggedinUserId = UserInfo.getUserId();
        String contactId;
        String prefCommMethod;
        String sUserWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedUser;
        Map<String, String> mapUserQueryParameters = new Map<String, String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.userobjectName,RE_DataBaseQueryFields.sFieldsToQueryOnUserForLoggedIn, mapUserQueryParameters);            
        List<User> loggedInUser = Database.query(userQuery);            
        Id userContactId = loggedInUser[0].ContactId;  
        
        List<Contact> lstContact = new List<Contact>();
        String sContactSafeQuery;
        String switchCaseKeyContact;
        Map<Boolean, String> mapResponseDataContact = new Map<Boolean, String>();
        Map<String, String> mapContactQueryParameters = new Map<String, String>();
        String sContactWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedContact;
        mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sContactWhereClause);
        mapContactQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        mapResponseDataContact = RE_DataAccessChecker.getFieldsAccessibility('Contact', 'AccountId,OptOutInfoSharing__c,ConsentToTexts__c,PreferredCommunicationMethod__c', mapContactQueryParameters);
        switchCaseKeyContact = (mapResponseDataContact.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKeyContact) {
            when 'success' {
                sContactSafeQuery =  mapResponseDataContact.get(true);
                lstContact = Database.query(sContactSafeQuery);
                contactId = lstContact[0].Id;
                prefCommMethod = lstContact[0].PreferredCommunicationMethod__c;
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','fetchConsentDetails','Some Fields doesn\'t have the required access :: '+mapResponseDataContact.get(false), true);
            }
        }
        
        List<Consent__c> lstConsentDetails = new List<Consent__c>();
        String sConsentSafeQuery;
        String switchCaseKey;
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapConsentPendingQueryParameters = new Map<String, String>();
        String sConsentFieldsApiName = RE_DataBaseQueryFields.sFieldsToConsentStatus;    
        String sFieldWhereCondition = RE_DataBaseQueryFields.sFieldConsentWhereClauseOnStatus;            
        mapConsentPendingQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sFieldWhereCondition);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Consent__c', sConsentFieldsApiName, mapConsentPendingQueryParameters);
        switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKey) {
            when 'success' {
                sConsentSafeQuery =  mapResponseData.get(true);
                //Bug 394514 - Payal Dubela
                //lstConsentDetails = Database.query(sConsentSafeQuery); 
                lstConsentDetails=RE_SharingByPassCtrl.getActiveConsents(sConsentSafeQuery,contactId);
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','fetchConsentDetails','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        
        List<String> lstConsentLevel = new List<String>{RE_GlobalConstants.ORGANIZATION,RE_GlobalConstants.ASSISTER};
        List<Consent__c> lstConsentNonPending = new List<Consent__c>();
        List<Consent__c> lstconsentCp = new List<Consent__c>();
        List<Consent__c> lstconsentAssist = new List<Consent__c>();
        List<Consent__c> lstconsentActive = new List<Consent__c>();
        
        String sConsentSafeQueryNonPending;
        String switchCaseKeyNonPending;
        Map<Boolean, String> mapResponseDataNonPending = new Map<Boolean, String>();
        Map<String, String> mapConsentNonActiveQuery = new Map<String, String>();
        String sConsentFieldsNonActiveApiName = RE_DataBaseQueryFields.sFieldsToConsentStatus;    
        String sFieldWhereNonActiveCondition = RE_DataBaseQueryFields.sFieldConsentNonActiveWhereClause;            
        mapConsentNonActiveQuery.put(RE_GlobalConstants.sWhereClauseKey, sFieldWhereNonActiveCondition);
        mapResponseDataNonPending = RE_DataAccessChecker.getFieldsAccessibility('Consent__c', sConsentFieldsNonActiveApiName, mapConsentNonActiveQuery);
        switchCaseKeyNonPending = (mapResponseDataNonPending.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKeyNonPending) {
            when 'success' {
                sConsentSafeQueryNonPending =  mapResponseDataNonPending.get(true);
                //Bug 394514 - Payal Dubela
                //lstConsentNonPending = Database.query(sConsentSafeQueryNonPending); 
                lstConsentNonPending=RE_SharingByPassCtrl.getPendingConsents(sConsentSafeQueryNonPending,contactId,lstConsentLevel);
            }
            when 'failure' { 
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','fetchConsentDetails','Some Fields doesn\'t have the required access :: '+mapResponseDataNonPending.get(false), true);
            }
        }
        
        try{
            
            for(Consent__c consent : lstConsentNonPending ){
                if(consent.ConsentLevel__c == RE_GlobalConstants.ORGANIZATION){
                    lstconsentCp.add(consent);
                    lstconsentActive.add(consent);
                }
                if(consent.ConsentLevel__c == RE_GlobalConstants.ASSISTER){
                    lstconsentAssist.add(consent);
                    lstconsentActive.add(consent);
                }
            }
            
            if(!lstConsentDetails.isEmpty()){
                mapResponse.put('consentDetails',lstConsentDetails);
                bSuccess = true;
            }
            if(!lstconsentCp.isEmpty()){
                mapResponse.put('consentOptCp',lstconsentCp);
                bSuccess = true;
            }
            if(!lstconsentAssist.isEmpty()){
                mapResponse.put('consentOptAssisters',lstconsentAssist);
                bSuccess = true;
            }
            if(!lstconsentActive.isEmpty()){
                mapResponse.put('consentOptActive',lstconsentActive);
                bSuccess = true;
            }
            if(!lstContact.isEmpty()){
                mapResponse.put('optInvalue',lstContact[0].OptOutInfoSharing__c);
                mapResponse.put('userAccountId',lstContact[0].AccountId);
                mapResponse.put('consentToText',lstContact[0].ConsentToTexts__c);
                mapResponse.put('prefCommMethod',lstContact[0].PreferredCommunicationMethod__c);
                
                bSuccess = true; 
            }
            
        }catch(Exception ex){
            errorMap.put('error', ex.getMessage());
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);        
    }
    
    /*********************************************************************************************************************************
* @author       SRIKANTH
* @date         06/20/2019
* @methodname   updateConsentStatus()
* @description  
* @param        Consent__c , String
* @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
    
    @AuraEnabled 
    public static RE_CreateLightningServerResponse updateConsentStatus(Consent__c objConsent, String strStatusValue){
        
        String statusValue = String.escapeSingleQuotes(strStatusValue);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        
        if(statusValue == RE_GlobalConstants.INACTIVE){
            objConsent.Status__c = RE_GlobalConstants.INACTIVE;
            objConsent.EndDate__c = System.today()-1;
        }
        if(statusValue == RE_GlobalConstants.ACTIVE){
            objConsent.Status__c = RE_GlobalConstants.ACTIVE;
            objConsent.StartDate__c = System.today();
        }
        if(statusValue == RE_GlobalConstants.DENY){
            objConsent.Status__c = RE_GlobalConstants.INACTIVE;
        }
         
        objConsent.ConsentProvidedBy__c = RE_GlobalConstants.CONSENT_PROVIDEDBY_RESIDENT;
       
        if(objConsent.Id != null){
            try{
                //Bug 394514 - Payal Dubela
                //Database.SaveResult[] sr = RE_DataAccessChecker.updateObject(Consent__c.sObjectType, objConsent);
                 Boolean updateStatus= RE_SharingByPassCtrl.updateSobject(Consent__c.sObjectType, objConsent);
                mapResponse.put('updatedConsent',objConsent);
                bSuccess = true;
                //Nandita: 357475: delete favorite client records on consent revoke
                if( objConsent.Status__c == RE_GlobalConstants.INACTIVE)
                {
                    deleteFavoriteClient(objConsent.client__c);
                }
            }catch(Exception ex){
                errorMap.put('error', ex.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','fetchConsentDetails','Error Occured: '+ex.getMessage(), true);}
            
                
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);  
    }
      
    /*********************************************************************************************************************************
* @author       SRIKANTH
* @date         06/20/2019
* @methodname   updateAccountOpt()
* @description  
* @param        hasAccountOpt
* @return       RE_CreateLightningServerResponse 
************************************************************************************************************************************/
    
    @AuraEnabled 
    public static RE_CreateLightningServerResponse updateAccountOpt(Boolean hasAccountOpt,String strUserAccountId){
       
        String userAccountId = String.escapeSingleQuotes(strUserAccountId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        
        Account objAccount = new Account();
        String sAccountSafeQuery;
        String switchCaseKey;
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapAccountQueryParameters = new Map<String, String>();
        String sFieldWhereCondition = RE_DataBaseQueryFields.sUserAccountId;            
        mapAccountQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sFieldWhereCondition);
        mapAccountQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Account', 'Id,HasOptedOutOfAccount__c', mapAccountQueryParameters);
        switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKey) {
            when 'success' {
                sAccountSafeQuery =  mapResponseData.get(true);
                objAccount = Database.query(sAccountSafeQuery); 
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','fetchConsentDetails','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        if(hasAccountOpt == true){
            objAccount.HasOptedOutOfAccount__c = true;
        }
        if(hasAccountOpt == false){
            objAccount.HasOptedOutOfAccount__c = false;
        }
        Id loggedinUserId = UserInfo.getUserId();
        String sUserWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedUser;
        Map<String, String> mapUserQueryParameters = new Map<String, String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.userobjectName,RE_DataBaseQueryFields.sFieldsToQueryOnUserForLoggedIn, mapUserQueryParameters);            
        List<User> loggedInUser = Database.query(userQuery);            
        Id userContactId = loggedInUser[0].ContactId; 
        
        List<String> lstConsentLevel = new List<String>{RE_GlobalConstants.ORGANIZATION,RE_GlobalConstants.ASSISTER};
        List<String> lstConsentStatus = new List<String>{RE_GlobalConstants.ACTIVE,RE_GlobalConstants.PENDING};
        List<Consent__c> lstConsentData = new List<Consent__c>();
        List<Consent__c> lstConsent = new List<Consent__c>();
       
        String sConsentSafeQuery;
        String switchCaseKeyConsent;
        Map<Boolean, String> mapResponseDataConsent = new Map<Boolean, String>();
        Map<String, String> mapConsentParameters = new Map<String, String>();
        String sConsentFieldsApiName = RE_DataBaseQueryFields.sFieldConsentFieldsStatus;    
        String sFieldConsentWhereCondition = RE_DataBaseQueryFields.sFieldConsentWhereConditionStatus;            
        mapConsentParameters.put(RE_GlobalConstants.sWhereClauseKey, sFieldConsentWhereCondition);
        mapResponseDataConsent = RE_DataAccessChecker.getFieldsAccessibility('Consent__c', sConsentFieldsApiName, mapConsentParameters);
        switchCaseKeyConsent = (mapResponseDataConsent.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKeyConsent) {
            when 'success' {
                sConsentSafeQuery =  mapResponseDataConsent.get(true);
                //Bug 394514 - Payal Dubela
                lstConsentData=RE_SharingByPassCtrl.getConsentsToRemove(sConsentSafeQuery,lstConsentLevel,lstConsentStatus,userContactId);
                //lstConsentData = Database.query(sConsentSafeQuery); 
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','fetchConsentDetails','Some Fields doesn\'t have the required access :: '+mapResponseDataConsent.get(false), true);
            }
        }
        if(hasAccountOpt == true){
            for(Consent__c consent : lstConsentData ){
                if(consent.Status__c == RE_GlobalConstants.ACTIVE ){
                    consent.Status__c = RE_GlobalConstants.INACTIVE;
                    consent.EndDate__c = System.today()-1;
                    lstConsent.add(consent);
                }
                if(consent.Status__c == RE_GlobalConstants.PENDING){
                    consent.Status__c = RE_GlobalConstants.INACTIVE;
                    lstConsent.add(consent);
                }
            }
        }
        try{
            if(objAccount.Id != null){
                RE_SharingByPassCtrl.updateSobject(objAccount.getSobjectType(), objAccount);
                mapResponse.put('updatedAccount',objAccount);
            }
            //Nandita: Added delete favorites function if client opts out : 357475 Release 1.1
            if(hasAccountOpt == true){
                deleteFavoriteClient(userContactId);
            }
            if(!lstConsent.isEmpty()){
                //Bug 394514 - Payal Dubela
                //Database.SaveResult[] sr = RE_DataAccessChecker.updateObjects(Consent__c.sObjectType, lstConsent);
                Boolean updateStatus= RE_SharingByPassCtrl.updateSobjects(Consent__c.sObjectType, lstConsent);
                mapResponse.put('updatedConsent',lstConsent);
            }
            bSuccess = true;
        }
        catch(Exception ex){            
            errorMap.put('error', ex.getMessage()); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','fetchConsentDetails','Error Occured: '+ex.getMessage(), true);   }
 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);        
    }
    /********************************************************************************************
* @author       Nandita Bapaye
* @date         04/01/2020
* @methodname   deleteFavoriteClient
* @description  This methods is used to delete favorite Client when clients opts out.
* @return       
**********************************************************************************************/     
    @AuraEnabled
    public static void deleteFavoriteClient(String strClientId){
        String sClientId = String.escapeSingleQuotes(strClientId);
        GeneralUtility.isAuthenticatedUser();
        
        List<Favorite__c> lstFav = new List<Favorite__c>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        if (String.isNotBlank(sClientId)) { 
            //String sContactId = GeneralUtility.getLoggedInUserContactId();
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnFavoriteClient;
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_DELETE_FAVORITE_CLIENTS;
            Id sFavRecordTypeId= GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sFavoriteObjectName, RE_GlobalConstants.sFavoriteDeveloperName);
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sFavoriteObjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    LstFav = RE_SharingByPassCtrl.getFavoriteClients(sQuery,sClientId,null,sFavRecordTypeId);
                    
                    
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PrivacySettingCtrl','deleteFavoriteClient','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            if (lstFav.isEmpty()) {
               
            }else{
                try{
                      RE_SharingByPassCtrl.deleteFavoriteClients(lstFav);                
                    
                }
                catch(Exception e){
                    errorMap.put('error', e.getMessage());
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl', 'removeFavoriteClient', e.getMessage() +' ' +e.getLineNumber(),true);
                }
            }
        }
        
        
    } 
}