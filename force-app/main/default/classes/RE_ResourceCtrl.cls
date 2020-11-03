/**************************************************************************************************
* Class Name    : RE_ResourceCtrl
* Owner         : Sai Kiran
* Created Date  : 05/02/2019
* Description   : Resource controller class for fetching resource summary details
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/18/2019  Karthik Gulla   Updated to include changes to add new Resource
**/
public with sharing class RE_ResourceCtrl {

    @AuraEnabled
    public static RE_CreateLightningServerResponse getResourceSummary(String resourceRecId) {
        GeneralUtility.isAuthenticatedUser();
        String strResourceId=String.isNotBlank(resourceRecId)?String.escapeSingleQuotes(resourceRecId):'';
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Id, Resource__c> mapLocationResource = new Map<Id, Resource__c>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sQuery;
        String switchCaseKey;
        Boolean checkToDisableButton = false;
        try {            
            RE_ResourceWrapper objWrapper;
            String sFieldsApiName;
            String sWhereClause;
            List<Location__c> lstOrgLocations;
            String sLocationQuery;
            List<LocationResource__c> lstLocationResource;
            Set<Id> setLocationIds = new Set<Id>();

            lstOrgLocations = (List<Location__c>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.sFieldsToQueryOnLocation, RE_DataBaseQueryFields.sWhereClauseWhereAccount, 'Location__c'), null, setLocationIds);
            if(strResourceId != null && strResourceId != ''){            
                Resource__c objRes = new Resource__c();
                objRes.Id = strResourceId;
                RE_ResourceWrapper rsWrapper = new RE_ResourceWrapper(objRes, lstOrgLocations, lstLocationResource, checkToDisableButton, null, null);
                List<Resource__c> lstResources = (List<Resource__c>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.RE_ResourceCtrlQuery, RE_DataBaseQueryFields.sWhereClauseRE_ResourceCtrl, 'Resource__c'), rsWrapper, setLocationIds);
                Resource__c objResource = !lstResources.isEmpty() ? lstResources[0] : null;

                lstLocationResource = (List<LocationResource__c>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.sQueryLocationFields, RE_DataBaseQueryFields.sWhereClauseLocation, 'LocationResource__c'), rsWrapper, setLocationIds);
                checkToDisableButton = (Boolean)getCheckToDisableButton().objectData.get('checkToDisable');

                List<RE_Resource_Taxonomy__c> lstExistResourceTaxonomyRecords = (List<RE_Resource_Taxonomy__c>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.sQueryFieldsResourceTaxonomy, RE_DataBaseQueryFields.sWhereClauseLocationRecId, 'RE_Resource_Taxonomy__c'), rsWrapper, setLocationIds);
                if(!lstExistResourceTaxonomyRecords.isEmpty()){
                    objWrapper = new RE_ResourceWrapper(objResource, lstOrgLocations, lstLocationResource, checkToDisableButton, null, lstExistResourceTaxonomyRecords[0]);
                } else{
                    objWrapper = new RE_ResourceWrapper(objResource, lstOrgLocations, lstLocationResource, checkToDisableButton, null, null);
                }
			}else{
                List<Account> lstAccounts = (List<Account>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.sAccountFields, RE_DataBaseQueryFields.sWhereClauseIdInRecordId, 'Account'), null, setLocationIds);
                objWrapper = new RE_ResourceWrapper(null, lstOrgLocations, new List<LocationResource__c>(), null, lstAccounts[0], null);
            }
            bSuccess = true;
            mapResponse.put('summarydata', objWrapper);
            /* added by Suresh  Starts :::*/
            Boolean bHasPermission = RE_OrganizationDetailsCtrl.userPermissionAccess();
            mapResponse.put('isAdminUser', bHasPermission);
             /* added by Suresh  Ends :::*/
             Boolean bAgencyHasPermission = RE_OrganizationDetailsCtrl.agencyUserPermissionAccess();
             mapResponse.put('isAgencyUser', bAgencyHasPermission);
        } catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceCtrl','getResourceSummary', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /**************************************************************************************
    * @author       Sai Kiran Velpula
    * @date         08/05/2019
    * @methodname   updateResourceDetails()
    * @description  This methods is used to update the Resource Object records.
    * @param        resId           (String)   : Resource Object ID
    * @param        res             (String)   : Resource Record details
    * @param        SelectedValues  (List)      : List of Selected Locations details
    * @param        unSelectedValues(List)     : List of unSelected Locations details
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateResourceDetails(String strResourceInputs, List<Location__c> lstSelectedValues, List<Location__c> lstUnselectedValues) {
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Map<String, Object> mapErrors = new Map<String, Object>();        
        Map<ID, String> mapExistingLocations = new Map<Id,String>();
        List<LocationResource__c> lstNewLocationResources = new List<LocationResource__c>();
        List<LocationResource__c> lstExistLocationResources = new List<LocationResource__c>();        
        Set<Id> setLocationIds = new Set<Id>();
        Database.DeleteResult[] drLocationResourceList;
        Database.SaveResult[] srLocationResourceList;
        Database.SaveResult[] srResource;
        RE_ResourceWrapper resWrapper = (RE_ResourceWrapper) JSON.deserialize(strResourceInputs, RE_ResourceWrapper.class);
        try {
           Resource__c resource = new Resource__c();
            resource.Name = resWrapper.Name;
            resource.SdohDomain__c = resWrapper.SDOHCategory; // added by Pankaj[11/25/2019] as part of Bug#339798
           if (RE_DataAccessChecker.isAllowedToUpdate(Resource__c.getSObjectType()) && resWrapper.Id != null) {                     
                resource.Id = resWrapper.Id;
                srResource = RE_DataAccessChecker.updateObject(Resource__c.getSObjectType(), resource);
            }else if(RE_DataAccessChecker.isAllowedToCreate(Resource__c.getSObjectType()) && resWrapper.Id == null){
                resource.Organization__c = resWrapper.AccountId;
                srResource = RE_DataAccessChecker.insertObject(Resource__c.getSObjectType(), resource);
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourceCtrl', 'updateResourceDetails','No Create/Update Access on Resource__c Object',true);
            }
            resWrapper.Id = resource.Id;
            RE_ResourceCtrl.GenericResult genSaveResult = new RE_ResourceCtrl.GenericResult(srResource);

            if(resWrapper.Id != null){
                //Create a Resource Taxonomy Record if it does not exist, else update
                List<RE_Resource_Taxonomy__c> lstExistResourceTaxonomyRecords = (List<RE_Resource_Taxonomy__c>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.sQueryIdName, RE_DataBaseQueryFields.sWhereClauseLocationRecId, 'RE_Resource_Taxonomy__c'), resWrapper, setLocationIds);
                RE_Resource_Taxonomy__c resTaxonomy = new RE_Resource_Taxonomy__c();
                if(!lstExistResourceTaxonomyRecords.isEmpty()
                    && RE_DataAccessChecker.isAllowedToUpdate(RE_Resource_Taxonomy__c.getSObjectType())){
                    resTaxonomy = lstExistResourceTaxonomyRecords[0];
                    resTaxonomy.Taxonomy__c = resWrapper.TaxonomyId;
                        RE_DataAccessChecker.updateObject(RE_Resource_Taxonomy__c.getSObjectType(), resTaxonomy);
                }else{                    
                    resTaxonomy.Resource__c = resWrapper.Id;
                    resTaxonomy.Taxonomy__c = resWrapper.TaxonomyId;
                    if(RE_DataAccessChecker.isAllowedToCreate(RE_Resource_Taxonomy__c.getSObjectType())){
                        RE_DataAccessChecker.insertObject(RE_Resource_Taxonomy__c.getSObjectType(), resTaxonomy);
                    }
                }
                
                lstExistLocationResources = (List<LocationResource__c>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.sQueryLocationFields, RE_DataBaseQueryFields.sWhereClauseLocationRecId, 'LocationResource__c'), resWrapper, setLocationIds);
                for (LocationResource__c locResource : lstExistLocationResources){
                    mapExistingLocations.put(locResource.Location__c, locResource.Location__r.Name);
                }
            }
			
            for (Location__c objLocation : lstSelectedValues) {
                if (!mapExistingLocations.containsKey(objLocation.Id)) {
                    LocationResource__c objLocationResource = new LocationResource__c();
                    objLocationResource.Location__c = objLocation.Id;
                    objLocationResource.Resource__c = resWrapper.Id;
                    lstNewLocationResources.add(objLocationResource);
                }                    
            }

            for (Location__c objLocation : lstUnselectedValues){                                        
                if (mapExistingLocations.containsKey(objLocation.Id)) {
                    setLocationIds.add(objLocation.Id);
                }                    
            }

			if (setLocationIds != null && !setLocationIds.isEmpty()) { 
                List<LocationResource__c> lstToBeDeleted = (List<LocationResource__c>)getQueryResults(getQueryDetails(RE_DataBaseQueryFields.sFieldsToQueryOnLocation, RE_DataBaseQueryFields.sWhereLocationIdFilter, 'LocationResource__c'), resWrapper, setLocationIds);                
                if (RE_DataAccessChecker.isAllowedToDelete(LocationResource__c.getSObjectType())) {
                    drLocationResourceList = RE_DataAccessChecker.deleteObjects(LocationResource__c.getSObjectType(), lstToBeDeleted);
                    RE_ResourceCtrl.GenericResult genDelResult = new RE_ResourceCtrl.GenericResult(drLocationResourceList);  
                } else {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourceCtrl', 'updateResourceDetails','No Delete Access on LocationResource__c Object',true);
                }
            }
            //Force Reviewer Changes - Payal Dubela -08/28
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyNewLocRes = (lstNewLocationResources!=null && !lstNewLocationResources.isEmpty())? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyNewLocRes) {
             when SWITCH_SUCCESS {  
                if(RE_DataAccessChecker.isAllowedToCreate(LocationResource__c.getSObjectType())){                
                    srLocationResourceList = RE_DataAccessChecker.insertObjects(LocationResource__c.getSObjectType(), lstNewLocationResources, false);
                    RE_ResourceCtrl.GenericResult genInsertResult = new RE_ResourceCtrl.GenericResult(srLocationResourceList);
                }
                else{
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourceCtrl', 'updateResourceDetails','No Access on LocationResource__c Object',true);
                }
              }
           } 
            bSuccess = true;
            mapResponse.put('updatedResourceID', resource.Id);
        } catch(Exception e) {
            mapErrors.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceCtrl', 'updateResourceDetails', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, mapErrors, mapResponse);
    }
    
    /**************************************************************************************
    * @author       Sai Kiran Velpula
    * @date         08/05/2019
    * @methodname   getPickListValues()
    * @description  This methods is used to get the picklist values from given sObject
    * @param        objectName          (String)   : sObject Name
    * @param        lstFields           (String)   : Multiple picklists separated by (,)
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getPickListValues(String objectName, String lstFields){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        try {
            Map<String,Map<String,String>> values = GeneralUtility.fetchFieldsPicklistValueAPIName(String.escapeSingleQuotes(objectName), String.escapeSingleQuotes(lstFields));
            bSuccess = true;
            mapResponse.put('picklistvalues', values);
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceCtrl','getPickListValues',e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }

    /**************************************************************************************
    * @author       Karthik Gulla
    * @date         07/24/2019
    * @methodname   getQueryDetails()
    * @description  This methods is form parameters required for SOQL
    * @param        mapQueryFields      (Map<String,String>)    : map of key, value pairs
    * @param        rsWrapper           (RE_ResourceWrapper)    : Wrapper with Resourc details
    * @param        setLocIds           (Set<Id>)               : set of Location Ids
    * @return       List<sObject>
    ******************************************************************************************/
    public static Map<String, String> getQueryDetails(String sFieldsApiName, String sWhereClause, String sObjectName){
        Map<String, String> mapQryInputs = new Map<String,String>();
        mapQryInputs.put('fieldsApiName', sFieldsApiName);
        mapQryInputs.put('whereClause', sWhereClause);
        mapQryInputs.put('objectName', sObjectName);
        return mapQryInputs;
    }

    /**************************************************************************************
    * @author       Karthik Gulla
    * @date         07/24/2019
    * @methodname   getQueryResults()
    * @description  This methods is used to get Query results
    * @param        mapQueryFields      (Map<String,String>)    : map of key, value pairs
    * @param        rsWrapper           (RE_ResourceWrapper)    : Wrapper with Resourc details
    * @param        setLocIds           (Set<Id>)               : set of Location Ids
    * @return       List<sObject>
    ******************************************************************************************/
    public static List<sObject> getQueryResults(Map<String, String> mapQueryInputs, RE_ResourceWrapper rsWrapper, Set<Id> setLocIds){
        String sQuery;
        String sSwitchCaseKey;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        List<sObject> lstQueryResults = new List<sObject>();
        Set<Id> locationIds;
        Set<Id> setVersionIds;
        String resId;
        String resourceRecId;
        Id contentNoteId;
        Id contentVersionId;
    //   Added By Kojashree -- SSP Merge
 		String recordId = GeneralUtility.getLoggedInAccountId();

        //Bind Variables
        if(rsWrapper != null){
            resId = rsWrapper.Id != null ? rsWrapper.Id : '';
            resourceRecId = resId;
        }
        String sAccountId = recordId;
        String sUserId = UserInfo.getUserId();

        if(setLocIds != null && !setLocIds.isEmpty()){
            locationIds  = new Set<Id>(setLocIds);
        }
        
        if(mapQueryInputs != null && mapQueryInputs.containsKey('contentNoteId')){
            contentNoteId = mapQueryInputs.get('contentNoteId');
        }else if(mapQueryInputs != null && mapQueryInputs.containsKey('contentVersionId')){
            contentVersionId = mapQueryInputs.get('contentVersionId');
        }else if(mapQueryInputs != null && mapQueryInputs.containsKey('setVIds')){
            List<Object> lstCnotes = (List<Object>)JSON.deserializeUntyped(mapQueryInputs.get('setVIds'));
            setVersionIds = new Set<Id>();
            for(Object sObj:lstCnotes){
                setVersionIds.add(Id.valueOf(String.valueOf(sObj)));
            }  
        }

        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, mapQueryInputs.get('whereClause'));
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(mapQueryInputs.get('objectName'), mapQueryInputs.get('fieldsApiName'), mapQueryParameters);
        
        sSwitchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (sSwitchCaseKey) {
            when 'success' {
                sQuery =  mapResponseData.get(true);
                lstQueryResults = Database.query(sQuery); 
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceCtrl','getQueryResults','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        return lstQueryResults;
    }

    /**************************************************************************************
    * @author       Karthik Gulla
    * @date         07/24/2019
    * @methodname   getCheckToDisableButton()
    * @description  This methods is used to check whether to disable components on page
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getCheckToDisableButton(){
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Boolean bSuccess = false;
        try{            
            // Added By Kojashree -- SSP Merge
            String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
            if(selectedRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF || selectedRole == RE_GlobalConstants.CASE_WORKER){
               mapResponse.put('checkToDisable', true);
            }else{
               mapResponse.put('checkToDisable', false);
            }
            bSuccess = true;
        }catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceCtrl','getCheckToDisableButton', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }

    /**************************************************************************************
    * @author       Karthik Gulla
    * @date         07/24/2019
    * @classname    GenericResult()
    * @description  This class is used to log Database Operation results
    ******************************************************************************************/
    public class GenericResult{
        public GenericResult(List<Database.Error> errors){
            String msg = RE_GlobalConstants.sEmptyString;
            for(Database.Error err : errors) {                
                msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
            }
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourceCtrl.GenericResult','Constructor',msg,false);
        }
        /**************************************************************************************
	* @author       Karthik Gulla
	* @date         07/24/2019
	* @classname    GenericResult()
	* @description  This class is used to log Database Operation results
	******************************************************************************************/
        public GenericResult(List<Database.SaveResult> lstResults){
            List<Database.Error> lstErrors = new List<Database.Error>();
            for(Database.SaveResult dbSaveResult : lstResults){
                if (!dbSaveResult.isSuccess()) {
                    lstErrors.addAll(dbSaveResult.getErrors());
                }
            }
            new GenericResult(lstErrors);
        }
        /**************************************************************************************
	* @author       Karthik Gulla
	* @date         07/24/2019
	* @classname    GenericResult()
	* @description  This class is used to log Database Operation results
	******************************************************************************************/
        public GenericResult(List<Database.DeleteResult> lstResults){
            List<Database.Error> lstErrors = new List<Database.Error>();
            for(Database.DeleteResult dbDelResult : lstResults){
                if (!dbDelResult.isSuccess()) {
                    lstErrors.addAll(dbDelResult.getErrors());
                }
            }
            new GenericResult(lstErrors);
        }
    }
    /* this method has been moved from Sharing By pass to this class */
    /********************************************************************************************
* @author       Sai Kiran
* @date         10/07/2019
* @methodname   fetchLocResource()
* @description  This methods is used to get the LocationResource__c Data
* @param        Resource ID, LocationID           (String)   : contact Id
* @return       Map<String,Integer>  
**********************************************************************************************/  
    public static List<Resource__c> fetchResourceData(Set<String> setResourcesIds){
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Id contactId;
        String sResourceQuery;
        String sFieldsApiName;
        String sWhereClause;
        String switchCaseKey;
        String sWhereClauseReferral;
        List<Resource__c> lstResources;
        try{
            String sAccountStatus = RE_GlobalConstants.sAccountStatus;
            sFieldsApiName = RE_DataBaseQueryFields.RDResidentViewResourceQuery;
            sWhereClause = RE_DataBaseQueryFields.sWhereClauseResourceRDResidentViewCtrl;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            sResourceQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('Resource__c', RE_DataBaseQueryFields.RDResidentViewResourceQueryToLabel, mapQueryParameters);
            String sRelationshipName;
            for(ChildRelationship rel: Resource__c.SObjectType.getDescribe().getChildRelationships()) {
                if(rel.getChildSObject() == Referral__c.SObjectType) {
                    sRelationshipName = rel.getRelationshipName();
                    break;
                } 
            }
            if (UserInfo.getUserType() == 'Guest') {
                sWhereClauseReferral = 'UserComplete__c = false AND Status__c !=: sClosed';
            }else{
                contactId = GeneralUtility.getLoggedInUserContactId(); 
                sWhereClauseReferral = RE_DataBaseQueryFields.sWhereClauseReferralRDResidentViewCtrl;
            }
            String sChildReferralQuery;
            String sFieldsApiNameReferral = RE_DataBaseQueryFields.sQueryReferralFieldsRDResidentViewCtrl;
            String sClosed = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
            Map<Boolean, String> mapResponseDataReferral = new Map<Boolean, String>();
            Map<String, String> mapQueryParametersReferral = new Map<String, String>();
            mapQueryParametersReferral.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseReferral);
            if(UserInfo.getUserType() != RE_GlobalConstants.GUEST){
                mapResponseDataReferral = RE_DataAccessChecker.getFieldsAccessibility('Referral__c', sFieldsApiNameReferral, mapQueryParametersReferral);
                switchCaseKey = (mapResponseDataReferral.get(true) != null) ? 'success' : 'failure';                                                                                
                switch on (switchCaseKey) {
                    when 'success' {
                        sChildReferralQuery = mapResponseDataReferral.get(true).Split('FROM')[0];
                        sChildReferralQuery += RE_GlobalConstants.SOQL_FROM +sRelationshipName + RE_GlobalConstants.SOQL_WHERE +sWhereClauseReferral;
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RDResidentViewCtrl','getResourceData','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                    } 
                }   
            }
            else{
                sChildReferralQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Referral__c', sFieldsApiNameReferral, mapQueryParametersReferral).Split('FROM')[0];
                sChildReferralQuery += RE_GlobalConstants.SOQL_FROM +sRelationshipName + RE_GlobalConstants.SOQL_WHERE +sWhereClauseReferral;
            }
            List<String> lstQuertStringSpilt =  sResourceQuery.split('FROM');  
            if(sChildReferralQuery !=null){
                sResourceQuery =  lstQuertStringSpilt[0] +','+ RE_DataBaseQueryFields.RESOURCE_SUBQUERY + RE_GlobalConstants.SOQL_FROM  + lstQuertStringSpilt[1]; 
            }
            Map<String, Object> mapInputs = new Map<String, Object>();
            mapInputs.put('sClosed',sClosed);
            mapInputs.put('contactId',contactId);
            mapInputs.put('setResourcesIds',setResourcesIds);
            mapInputs.put('sAccountStatus',sAccountStatus);
            mapInputs.put('sResourceQuery',sResourceQuery);
            lstResources = RE_SharingByPassCtrl.fetchResourceData(mapInputs);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourceCtrl','fetchResourceData',e.getStackTraceString(),true);
        }
        return lstResources;
    }
}