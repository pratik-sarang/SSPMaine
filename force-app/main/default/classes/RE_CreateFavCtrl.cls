/**
* Class Name    : RE_CreateFavCtrl
* Owner         : DELOITTE
* Created Date  : 17/07/2019
* Description   : 
*                            M O D I F I C A T I O N   L O G                                          
*
* Date        Developer       Description                                                         
* ----------  -----------     --------------------------------------------------------------------
*  17/07/2019  Suyash       Initial Version
*  
**/
public inherited sharing class RE_CreateFavCtrl {
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   createFavorite
    * @description  This methods is used to cerate favorite object based on location resource id
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/ 
    @AuraEnabled
    public static RE_CreateLightningServerResponse createFavorite(String strLocationResId){
        
        String sLocationResId = String.escapeSingleQuotes(strLocationResId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        List<Favorite__c> lstFav = new List<Favorite__c>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        
        
        if (String.isNotBlank(sLocationResId)) {
            //--Defect#342578 - fetching the record to check if the favorite record exists in salesforce         
            String sContactId = GeneralUtility.getLoggedInUserContactId();
            String sFieldsApiName = RE_DataBaseQueryFields.FIELDS_CREATE_FAVORITES;
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_CREATE_FAVORITES;
            Id sFavRecordTypeId=Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Resource Favorite').getRecordTypeId();
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Favorite__c', sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    lstFav = Database.query(sQuery); 
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl','createFavorite','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            if (!lstFav.isEmpty()) {
                bSuccess = false;
            }else{
                Favorite__c objFav = new Favorite__c();
                objFav.LocationResource__c = sLocationResId;
                objFav.Contact__c = GeneralUtility.getLoggedInUserContactId();
                objFav.recordtypeid = sFavRecordTypeId;
                
                try{
                    //RE_DataAccessChecker.insertObject(Favorite__c.sObjectType,objFav);
                     RE_SharingByPassCtrl.insertSobject(Favorite__c.getSObjectType(), objFav);                
                    bSuccess = true;
                }
                catch(Exception e){
                    errorMap.put('error', e.getMessage());
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl', 'createFavorite', e.getMessage() +' ' +e.getLineNumber(),true);
                }
            }
        }
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
        
    }
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   deleteFavorite
    * @description  This methods is used to delete favorite object based on location resource id
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/ 
    @AuraEnabled
    public static RE_CreateLightningServerResponse deleteFavorite(String strLocationResId){
        
        String sLocationResId = String.escapeSingleQuotes(strLocationResId);
	GeneralUtility.isAuthenticatedUser();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        List<Favorite__c> lstFav = new List<Favorite__c>();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        if (String.isNotBlank(sLocationResId)) {
            String sContactId = GeneralUtility.getLoggedInUserContactId();
            String sFieldsApiName = RE_DataBaseQueryFields.FIELDS_DELETE_FAVORITES;
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_DELETE_FAVORITES;
            Id sFavRecordTypeId=Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Resource Favorite').getRecordTypeId();
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Favorite__c', sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    lstFav = Database.query(sQuery); 
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl','deleteFavorite','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            if (!lstFav.isEmpty()) {
               bSuccess = true; 
                try{ 
               		RE_DataAccessChecker.deleteObjects(Favorite__c.sObjectType,lstFav);
                }catch(Exception e){
                	errorMap.put('error', e.getMessage());
                	LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl', 'createFavorite', e.getMessage() +' ' +e.getLineNumber(),true);
            	}
            }
        }
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }
    /********************************************************************************************
* @author       Nandita Bapaye
* @date         03/26/2020
* @methodname   createFavoriteClient
* @description  This methods is used to cerate favorite Client object based on Client id
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/     
    @AuraEnabled
    public static RE_CreateLightningServerResponse createFavoriteClient(String strClientId){
        String sClientId = String.escapeSingleQuotes(strClientId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        List<Favorite__c> lstFav = new List<Favorite__c>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        if (String.isNotBlank(sClientId)) { 
            String sContactId = GeneralUtility.getLoggedInUserContactId();
            String sFieldsApiName = RE_DataBaseQueryFields.FIELDS_CREATE_FAVORITES;
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_CREATE_FAVORITE_CLIENTS;
            Id sFavClientRecordTypeId= GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sFavoriteObjectName, RE_GlobalConstants.sFavoriteDeveloperName);
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sFavoriteObjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    LstFav = RE_SharingByPassCtrl.getFavoriteClients(sQuery,sClientId,sContactId,sFavClientRecordTypeId);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl','createFavoriteClient','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            if (!lstFav.isEmpty()) {
                bSuccess = false;
            }else{
                Favorite__c objFav = new Favorite__c();
                objFav.Client__c = sClientId;
                objFav.Contact__c = sContactId;
                objFav.recordtypeid = sFavClientRecordTypeId;
                try{
                     RE_SharingByPassCtrl.insertSobject(Favorite__c.getSObjectType(), objFav);                
                     bSuccess = true;
                }
                catch(Exception e){
                    errorMap.put('error', e.getMessage());
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl', 'createFavoriteClient', e.getMessage() +' ' +e.getLineNumber(),true);
                }
            }
        }
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
        
    }
    
    /********************************************************************************************
* @author       Nandita Bapaye
* @date         03/26/2020
* @methodname   removeFavoriteClient
* @description  This methods is used to delete favorite Client object based on Client id
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/     
    @AuraEnabled
    public static RE_CreateLightningServerResponse removeFavoriteClient(String strClientId){
        String sClientId = String.escapeSingleQuotes(strClientId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        List<Favorite__c> lstFav = new List<Favorite__c>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        if (String.isNotBlank(sClientId)) { 
            String sContactId = GeneralUtility.getLoggedInUserContactId();
            String sFieldsApiName = RE_DataBaseQueryFields.FIELDS_CREATE_FAVORITES;
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_CREATE_FAVORITE_CLIENTS;
            Id sFavClientRecordTypeId= GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sFavoriteObjectName, RE_GlobalConstants.sFavoriteDeveloperName);
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sFavoriteObjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    LstFav = RE_SharingByPassCtrl.getFavoriteClients(sQuery,sClientId,sContactId,sFavClientRecordTypeId);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl','removeFavoriteClient','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            if (lstFav.isEmpty()) {
                bSuccess = false;
            }else{
                try{
                      RE_DataAccessChecker.deleteObjects(Favorite__c.sObjectType,lstFav);                
                     bSuccess = true;
                }
                catch(Exception e){
                    errorMap.put('error', e.getMessage());
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateFavCtrl', 'removeFavoriteClient', e.getMessage() +' ' +e.getLineNumber(),true);
                }
            }
        }
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
        
    }
}