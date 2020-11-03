/**************************************************************************************
 * @author       Pankaj Mohanta
 * @date         07/17/2019
 * @classname    RE_BasicSearchHelper
 * @description  This is a helper class for Search Utility
 ******************************************************************************************
 * Date		   Developer		Change Details
 * 12/02/2019  Pankaj	        Added logic for displaying resources with null values
 * 12/24/2019  Pankaj           Changed logic as part of #341424- perf issue
 /******************************************************************************************/
public with sharing class RE_BasicSearchHelper {
	/********************************************************************************************
    * @author       Pankaj
    * @date         07/17/2019
    * @methodname   getLocationResources()
    * @description  This methods is used to get the locaion resources
    * @return       List<LocationResource__c>
    **********************************************************************************************/
    public static List<LocationResource__c> getLocationResources(Set<Id> setLocationResourceIds,Set<Id> setGlobalLocaResourceIds,Map<String, String> mapInputs){
        String sDomain = mapInputs.get('sDomain');
        Double dblLat = Double.valueOf(mapInputs.get('dblLat'));
        Double dblLon = Double.valueOf(mapInputs.get('dblLon'));
        Integer pageNumber=(mapInputs.containsKey('pageNumber') && mapInputs.get('iPageSize').isNumeric())?Integer.valueof(mapInputs.get('pageNumber')):0;// [Suresh] added Numeric check - SIT Error log fix
        Integer iPageSize=(mapInputs.containsKey('iPageSize')&& mapInputs.get('iPageSize').isNumeric())?Integer.valueof(mapInputs.get('iPageSize')):30;// [Suresh] added Numeric check - SIT Error log fix
        Integer offSet=pageNumber*iPageSize;
        List<LocationResource__c> lstLocationResources;
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        Map<String,String> mapLocResourceQueryParameters = new Map<String,String>();
        String sWhereClauseForLocResource = RE_GlobalConstants.sEmptyString;
        Map<Boolean,String> mapLocResourceResponse = new Map<Boolean,String>();
        String sOrderby = RE_DataBaseQueryFields.sOrderByClauseOnLocRes;
        String sLocResourceQuery;
        String sFieldsToQueryOnLocResource = RE_DataBaseQueryFields.sFieldsToQueryOnLocResource;
        mapLocResourceQueryParameters.put(RE_GlobalConstants.sLimitKey, String.valueof(iPageSize));
        mapLocResourceQueryParameters.put(RE_GlobalConstants.sOffset, String.valueof(offSet));
        if(sDomain == null){
            sWhereClauseForLocResource = RE_DataBaseQueryFields.sWhereClauseForLocResourceNoDomain;
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForLocResource);
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            mapLocResourceResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsToQueryOnLocResource,mapLocResourceQueryParameters);
            if(mapLocResourceResponse.get(true) != null){
                sLocResourceQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('LocationResource__c', RE_DataBaseQueryFields.sFieldsToQueryOnLocResourceToLabel,mapLocResourceQueryParameters);                
                Map<String, Object> mapDataInputs = new Map<String, Object>();
                mapDataInputs.put('setLocationResourceIds',setLocationResourceIds);
                mapDataInputs.put('setGlobalLocaResourceIds',setGlobalLocaResourceIds);
                mapDataInputs.put('sAccountStatus',sAccountStatus);
                mapDataInputs.put('dblLat',dblLat);
                mapDataInputs.put('dblLon',dblLon);
                mapDataInputs.put('sQuery',sLocResourceQuery);
                
                lstLocationResources = RE_SharingByPassCtrl.getLocationResources(mapDataInputs);  
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_BasicSearchHelper','getCategorySearchResults','***FLS Violation***'+mapLocResourceResponse.get(false),true);
            } 
        }else{
            sWhereClauseForLocResource = RE_DataBaseQueryFields.sWhereClauseForLocResourceWithDomain;
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForLocResource);
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            mapLocResourceResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsToQueryOnLocResource,mapLocResourceQueryParameters);
            if(mapLocResourceResponse.get(true) != null){
                sLocResourceQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('LocationResource__c', RE_DataBaseQueryFields.sFieldsToQueryOnLocResourceToLabel,mapLocResourceQueryParameters);                
                Map<String, Object> mapDataInputs = new Map<String, Object>();
                mapDataInputs.put('setLocationResourceIds',setLocationResourceIds);
                mapDataInputs.put('sAccountStatus',sAccountStatus);
                mapDataInputs.put('dblLat',dblLat);
                mapDataInputs.put('dblLon',dblLon);
                mapDataInputs.put('sQuery',sLocResourceQuery);
                mapDataInputs.put('sDomain',sDomain);
                lstLocationResources = RE_SharingByPassCtrl.getLocationResources(mapDataInputs);
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_BasicSearchHelper','getLocationResources','***FLS Violation***'+mapLocResourceResponse.get(false),true);
            } 
        }
        // added by Pankaj[12/02/2019] as part of #341424
        if(lstLocationResources.isEmpty() || (lstLocationResources!=null && lstLocationResources.size() < iPageSize)){
            // get only rest of records to maintain the off set and limit consistent
            if(lstLocationResources!=null && (lstLocationResources.size() < iPageSize)){
                    iPageSize = iPageSize - lstLocationResources.size();
            }
            String sQuery;
            Map<String, Object> mapDataInputs = new Map<String, Object>();
            Map<String,String> mapNullResourceQueryParameters = new Map<String,String>();
            Map<Boolean,String> mapNullLocResourceResponse = new Map<Boolean,String>();
            String sFieldsToQueryOnLocResourceNullResources = RE_DataBaseQueryFields.sFieldsToQueryOnLocResource;
            String sWhereClasueForNullResources= RE_DatabaseQueryFields.sWhereClasueForNullResources;
            mapNullResourceQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClasueForNullResources);
            mapNullResourceQueryParameters.put(RE_GlobalConstants.sLimitKey, String.valueof(iPageSize));
        	mapNullResourceQueryParameters.put(RE_GlobalConstants.sOffset, String.valueof(offSet));
            mapLocResourceResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsToQueryOnLocResourceNullResources, mapNullResourceQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCasemapResource= (mapLocResourceResponse.get(true) != null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCasemapResource) {
            when SWITCH_SUCCESS { 
                sQuery = mapLocResourceResponse.get(true);
                mapDataInputs.put('setLocationResourceIds',setLocationResourceIds);
                mapDataInputs.put('sAccountStatus',sAccountStatus);
                mapDataInputs.put('sQuery',sQuery);
                mapDataInputs.put('sDomain',sDomain);
                List<LocationResource__c> lstForLocationsWithoutAddress = RE_SharingByPassCtrl.getLocationResources(mapDataInputs);
                if(lstForLocationsWithoutAddress!=null && lstForLocationsWithoutAddress.size()>0){
                    lstLocationResources.addAll(lstForLocationsWithoutAddress);
                }
             }
          } 
        }
        return lstLocationResources;
    }
    /********************************************************************************************
    * @author       Pankaj
    * @date         07/17/2019
    * @methodname   getResidentReferrals()
    * @description  This methods is used to get the Resident Referrals
    * @return       Map<Id, Referral__c>
    **********************************************************************************************/
    public static Map<Id, Referral__c> getResidentReferrals(Set<Id> setResourceIds){
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        List<Referral__c> lstReferals = new List<Referral__c>();
        Map<String,String> mapQueryReferrals = new Map<String,String>();
        String sFieldsToQueryOnReferrals = RE_DataBaseQueryFields.sResourceFields;
        Map<Boolean,String> mapReferralResponse = new Map<Boolean,String>();
        String sWhereClauseForReferrals = RE_GlobalConstants.sEmptyString;
        String sReferralsQuery;
        if(UserInfo.getUserType() == 'Guest'){
            sWhereClauseForReferrals = RE_DataBaseQueryFields.sWhereClauseForReferrals;
            mapQueryReferrals.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForReferrals);
            mapReferralResponse = RE_DataAccessChecker.getFieldsAccessibility('Referral__c',sFieldsToQueryOnReferrals,mapQueryReferrals);
            if(mapReferralResponse.get(true) != null){
                sReferralsQuery =  mapReferralResponse.get(true);
                lstReferals = RE_SharingByPassCtrl.getRferralRecords(sReferralsQuery,null,setResourceIds);
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','getCategorySearchResults','***FLS Violation***'+mapReferralResponse.get(false),true);
            } 
        }else{
            Id contactId = GeneralUtility.getLoggedInUserContactId();
            sWhereClauseForReferrals = RE_DataBaseQueryFields.sWhereClauseForContactReferrals;
            //mapQueryReferrals.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForReferrals);
              mapQueryReferrals.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWhereClauseOnReferralSearchResult);
            mapReferralResponse = RE_DataAccessChecker.getFieldsAccessibility('Referral__c',sFieldsToQueryOnReferrals,mapQueryReferrals);
            if(mapReferralResponse.get(true) != null){
                sReferralsQuery =  mapReferralResponse.get(true);
                lstReferals = RE_SharingByPassCtrl.getRferralRecords(sReferralsQuery,contactId,setResourceIds);
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','getCategorySearchResults','***FLS Violation***'+mapReferralResponse.get(false),true);
            } 
        }
        Map<Id,Referral__c> mapResourceVsReferal = new Map<Id,Referral__c>();
        for(Referral__c objReferal: lstReferals){
            //mapResourceVsReferal.put(objReferal.Resource__c, objReferal);
            mapResourceVsReferal.put(objReferal.Location__c, objReferal);
        }
        return mapResourceVsReferal;
    }
    /********************************************************************************************
    * @author       Pankaj M
    * @date         09/19/2019
    * @methodname   getResourceIds()
    * @description  This methods is used to get the resource ids based on location resources
    * @return       Set<Id>
    **********************************************************************************************/
    public static Set<Id> getResourceIdsFromResourceLocation(Set<Id> setResLocationIds){
        Set<Id> setGlobalSearchResourceIds = new Set<Id>();
        List<LocationResource__c> lstLocResources = new List<LocationResource__c>();
        String sFieldsToQueryOnLocationResource = RE_DataBaseQueryFields.sFieldsTobeQueryOnLocationResource;
        String sWhereClauseOnLocationResource = RE_DataBaseQueryFields.sLocationResourceWhereClasue;
        Map<String,String> mapResourceLocationQueryParameters = new Map<String,String>();
        mapResourceLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocationResource);
        Map<Boolean,String> mapResourceLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c', sFieldsToQueryOnLocationResource, mapResourceLocationQueryParameters);
        String switchReferralKey = (mapResourceLocationQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchReferralKey) {
            when 'success' {
                String sQuery = mapResourceLocationQueryResponse.get(true);
                lstLocResources = RE_SharingByPassCtrl.getResourceIdsFromResourceLocation(setResLocationIds, sQuery);
            }
        }
        for(LocationResource__c resource : lstLocResources){
            if(resource.Resource__r.Organization__r.IsClaimed__c == false || (resource.Resource__r.Organization__r.IsClaimed__c == true && resource.Resource__r.Organization__r.Status__c == RE_GlobalConstants.sAccountStatus)){
            setGlobalSearchResourceIds.add(resource.Resource__c);
            } 
        }
        return setGlobalSearchResourceIds;
    }
    /********************************************************************************************
    * @author       Pankaj M
    * @date         09/19/2019
    * @methodname   getResourceTaxonomiesIds()
    * @description  This methods is used to get the resource Ids based on taxonomy ids
    * @return       set<ID>
    **********************************************************************************************/
    public static Set<Id> getResourceTaxonomiesIds(Set<Id> setTaxonomyIds){
        Set<Id> setGlobalSearchResourceIds = new Set<Id>();
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        List<RE_Resource_Taxonomy__c> lstLocResourceTaxonomy = new List<RE_Resource_Taxonomy__c>();
        String sFieldsToQueryOnResourceTaxonomy = RE_DataBaseQueryFields.sFieldsOnResTaxonomy;
        String sWhereClauseOnResourceTaxonomy = RE_DataBaseQueryFields.sWhereClauseForResTaxonomy;
        Map<String,String> mapResourceTaxonomiesQueryParameters = new Map<String,String>();
        mapResourceTaxonomiesQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnResourceTaxonomy);
        Map<Boolean,String> mapResourceTaxonomyQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('RE_Resource_Taxonomy__c', sFieldsToQueryOnResourceTaxonomy, mapResourceTaxonomiesQueryParameters);
        String switchResourceTaxonomyKey = (mapResourceTaxonomyQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchResourceTaxonomyKey) {
            when 'success' {
                String sQuery = mapResourceTaxonomyQueryResponse.get(true);
                lstLocResourceTaxonomy = Database.query(sQuery);
            }
        }
        for(RE_Resource_Taxonomy__c resource : lstLocResourceTaxonomy){
            setGlobalSearchResourceIds.add(resource.Resource__c);
        }
        return setGlobalSearchResourceIds;
    }
    /********************************************************************************************
    * @author       Pankaj M
    * @date         09/19/2019
    * @methodname   getUserLocation()
    * @description  This methods is used to get user location data
    * @return       Map<String, Object>
    **********************************************************************************************/
    public static Map<String, Object> getUserLocation(String sContactId, String sProfileName){
        Map<String, Object> mapReturnResponse = new Map<String, Object>();
        if(UserInfo.getUserType() != 'Guest'){
            Double dblLat;
            Double dblLon;
            String sUserLocation;
            Location objLocationData;
            Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sProfileName);
            if (objContact.ContactGeoLocation__c != null){
                objLocationData = objContact.ContactGeoLocation__c;
                dblLat = Double.valueOf(objLocationData.latitude);
                dblLon = Double.valueOf(objLocationData.longitude);
                sUserLocation = objLocationData.latitude+'##'+objLocationData.longitude;
            }
            mapReturnResponse.put('sUserLocation',sUserLocation);
            mapReturnResponse.put('dblLat',dblLat);
            mapReturnResponse.put('dblLon',dblLon);
        }
        return mapReturnResponse;
    }
    /********************************************************************************************
    * @author       Payal(Bug:342978)
    * @date         01/10/2020
    * @methodname   getLocationResourcesCount()
    * @description  This methods is used to get the locaion resources
    * @return       List<LocationResource__c>
    **********************************************************************************************/
    public static Double getLocationResourcesCount(Set<Id> setLocationResourceIds,Set<Id> setGlobalLocaResourceIds, Map<String, String> mapInputs){
        Double dblLat = Double.valueOf(mapInputs.get('dblLat'));
        Double dblLon = Double.valueOf(mapInputs.get('dblLon'));
        String sDomain = mapInputs.get('sDomain');
        List<AggregateResult> countLocationResources;
        Double totalcount=0;
        Map<String,String> mapLocResourceQueryParameters = new Map<String,String>();
        String sWhereClauseForLocResource = RE_GlobalConstants.sEmptyString;
        Map<Boolean,String> mapLocResourceResponse = new Map<Boolean,String>();
        String sLocResourceQuery;
        String sFieldsToQueryOnLocResource = RE_DataBaseQueryFields.sAggregateFieldsToQueryOnLocationResource;
        if(sDomain == null){
            sWhereClauseForLocResource = RE_DataBaseQueryFields.sWhereClauseForLocResourceNoDomain;
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForLocResource);
                sLocResourceQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('LocationResource__c', RE_DataBaseQueryFields.sAggregateFieldsToQueryOnLocationResource,mapLocResourceQueryParameters);
                Map<String, Object> mapDataInputs = new Map<String, Object>();
                mapDataInputs.put('setLocationResourceIds',setLocationResourceIds);
                mapDataInputs.put('setGlobalLocaResourceIds',setGlobalLocaResourceIds);
                mapDataInputs.put('dblLat',dblLat);
                mapDataInputs.put('dblLon',dblLon);
                mapDataInputs.put('sQuery',sLocResourceQuery);
                countLocationResources = RE_SharingByPassCtrl.getLocationResourcesCount(mapDataInputs);
                if(countLocationResources!=null && !countLocationResources.isEmpty()){
                    totalcount=(Double)countLocationResources[0].get('total');
                }
        }
        return totalcount;

    }
}