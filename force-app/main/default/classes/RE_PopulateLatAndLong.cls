/**
* Class Name    : RE_PopulateLatAndLong
* Owner         : DELOITTE
* Created Date  : 06/13/2019
* Description   : Poplating lat and long of location record using zipcode through google map api
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/13/2019  Arun       Initial Version
*  
**/
public with sharing class RE_PopulateLatAndLong {
    public static sObject calloutHttpMethod(sObject sObjData, String zip){
        SObject objReturn;
        try{
            Schema.SObjectType objectType = sObjData.getSObjectType();
            String sObjName = String.valueOf(objectType);
            String switchZipCodeKey = (String.isNotBlank(zip)) ? 'validzipcode' : 'invalidzipcode';    
            switch on (switchZipCodeKey) {
                when 'validzipcode' {
                    REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('RE_GoogleMapAPI');
                    String sApiKey = oIntEndpoints.Account_API_Key__c;
                    Map<String, Object> mapInputData =new Map<String, Object>();
                    String correctzip=String.escapeSingleQuotes(zip);
                    mapInputData.put('address',EncodingUtil.URLENCODE(correctzip,'UTF-8'));
                    mapInputData.put('key',sApiKey);
                    RE_GoogleMapGeoLocationResponseWrapper wrapper = (RE_GoogleMapGeoLocationResponseWrapper)RE_ServiceHandler.handleExecutionResults('GetGoogleMapApi',mapInputData).get(RE_GlobalConstants.RESP_CLIENT_DATA);
                    String sSwitchSuccessKey = (wrapper != null) ? 'success' : 'failure';
                    switch on (sSwitchSuccessKey) {
                        when 'success' {
                            objReturn = getWrapperData(wrapper, objectType, sObjData);
                        }
                        when 'failure'{
                            objReturn = updateGeoLocationField(sObjData);
                        }
                    }
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_PopulateLatAndLong','calloutHttpMethod',e.getMessage()+' '+e.getStackTraceString(),true);
        }
        return objReturn;
    }
    
    public static sObject getWrapperData(RE_GoogleMapGeoLocationResponseWrapper wrapper, Schema.SObjectType objectType, sObject sObjData){
        SObject objReturn;
        RE_GoogleMapGeoLocationResponseWrapper.Northeast loc;
        for(RE_GoogleMapGeoLocationResponseWrapper.Results r: wrapper.results){
            loc = new RE_GoogleMapGeoLocationResponseWrapper.Northeast();
            loc.lat = r.geometry.location.lat;
            loc.lng = r.geometry.location.lng;
        }
        String sLatLong = loc.lat+'##'+loc.lng;
        List<String> lstLatLong = new List<String>();
        if(sLatLong != null && objectType == Contact.getSObjectType()){
            lstLatLong = sLatLong.split('##');
            Contact objContact=(Contact)sObjData;
            objContact.ContactGeoLocation__Latitude__s = Double.valueOf(lstLatLong[0]);
            objContact.ContactGeoLocation__Longitude__s = Double.valueOf(lstLatLong[1]);
            objReturn = objContact;
        }else if(sLatLong != null && objectType == Location__c.getSObjectType()){
            lstLatLong = sLatLong.split('##');
            Location__c objLocation=(Location__c)sObjData;
            objLocation.GeoLocation__Latitude__s = Double.valueOf(lstLatLong[0]);
            objLocation.GeoLocation__Longitude__s = Double.valueOf(lstLatLong[1]);
            objReturn = objLocation;
        }
        return objReturn;
    }

    @InvocableMethod
    public static void populate(List<Id> lstIds){
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        String sQuery;
        String zipCode;
        Integer loopCount = 0;
        Integer iChunk = 0;
        Integer extraRecs = 0;
        List<Location__c> lstLocation = new List<Location__c>();
        List<Location__c> lstLocationChunk = new List<Location__c>();
        List<Contact> lstContact = new List<Contact>();
        List<Contact> lstContactChunk = new List<Contact>();        
        String sObjectName = lstIds[0].getSObjectType().getDescribe().getName();
        if(sObjectName == 'Location__c'){
            //Added by Shubham for PMD starts
            String sFieldsApiName = RE_DataBaseQueryFields.sPopulateLocationQuery;
            String sWhereClause = RE_DataBaseQueryFields.sPopulateLocationWhereClause;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocationObjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PopulateLatAndLong','populate','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                } 
            }
            lstLocation = database.query(sQuery);
            //Added by Shubham for PMD Ends
            //-------------------
            iChunk = lstLocation.size()/50 ; 
            extraRecs = Math.mod(lstLocation.size(),50) ; 
            for(Integer x = 1; x <= iChunk; x++){
                lstLocationChunk.clear();
                Boolean bInsert = false;
                RE_GlobalConstants.SWITCH_CONSTANTS switchKeySuccFail = (loopCount < (x)*50) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                switch on (switchKeySuccFail) {
                    when SWITCH_SUCCESS {
                    loopCount = (x-1)*50;
                    for(Integer i = (x-1)*50; i < (x)*50; i++){
                        lstLocationChunk.add(lstLocation[i]);
                        loopCount++;
                    }
                    if (loopCount == (x)*50 ){                    
                        //
                        System.enqueueJob(new RE_PopulateGeoLocationAsync(lstLocationChunk));
                    }
                    }
                }
            }
            lstLocationChunk.clear();
            for(Integer x = iChunk*50; x < iChunk*50 +extraRecs ; x++){
                lstLocationChunk.add(lstLocation[x]);
                loopCount++;
            }
            //
            System.enqueueJob(new RE_PopulateGeoLocationAsync(lstLocationChunk));
            //-------------------
        }else if(sObjectName == 'Contact'){
            //Added by Shubham for PMD Start
            String sFieldsApiName = RE_DataBaseQueryFields.sPopulateContactQuery ;
            String sWhereClause = RE_DataBaseQueryFields.sPopulateContactWhereClause ;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PopulateLatAndLong','populate','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                } 
            }
            lstContact = database.query(sQuery);
            //Added by Shubham for PMD End
            iChunk = lstContact.size()/50 ; 
            extraRecs = Math.mod(lstContact.size(),50) ; 
            for(Integer x = 1; x <= iChunk; x++){
                lstContactChunk.clear();
                Boolean bInsert = false;
                RE_GlobalConstants.SWITCH_CONSTANTS switchKeySuccFail = (loopCount < (x)*50) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                switch on (switchKeySuccFail) {
                    when SWITCH_SUCCESS {
                    loopCount = (x-1)*50;
                    for(Integer i = (x-1)*50; i < (x)*50; i++){
                        lstContactChunk.add(lstContact[i]);
                        loopCount++;
                    }
                    if (loopCount == (x)*50 ){                    
                        System.enqueueJob(new RE_PopulateGeoLocationAsync(lstContactChunk));
                    }
                    } 
                }
            }
            lstContactChunk.clear();
            for(Integer x = iChunk*50; x < iChunk*50 +extraRecs ; x++){
                lstContactChunk.add(lstContact[x]);
                loopCount++;
            }
            System.enqueueJob(new RE_PopulateGeoLocationAsync(lstContactChunk));
            //-------------------
        }
        }
        
    public static sObject updateGeoLocationField(sObject sObjData){
        sObject objdata;
        Schema.SObjectType objectType = sObjData.getSObjectType();
        String switchKey = (objectType ==Contact.getSObjectType()) ? 'Contact' : 'Location__c';     
        switch on (switchKey) {
            when 'Contact' {
                Contact objContact=(Contact)sObjData;
                objContact.ContactGeoLocation__Latitude__s = null;
                objContact.ContactGeoLocation__Longitude__s = null;
                objdata = objContact;
            }
            when 'Location__c' {
                Location__c objLocation=(Location__c)sObjData;
                objLocation.GeoLocation__Latitude__s = null;
                objLocation.GeoLocation__Longitude__s = null;
                objdata = objLocation;
            }
        }
        return objdata;
    }
    //@future(callout=true)
    public static sObject calloutmethod(sObject sObj, String objectName, String zipCode){
        sObject objdata;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        String sQuery;
        if(objectName == 'Contact'){
            Contact contactDetails=new Contact();
            String sFieldsApiName = RE_DataBaseQueryFields.sPopulatelatAndLongContactQuery;
            String sWhereClause = RE_DataBaseQueryFields.sPopulatelatAndLongContactWhereClause;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    objdata = RE_PopulateLatAndLong.calloutHttpMethod((Contact)sObj,zipCode); //[Anuj] changes made corresponding to One View 1359
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PopulateLatAndLong','populate','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                } 
            }
        }
        if(objectName == 'Location__c'){
            Location__c objLocation=new Location__c(); 
            String sFieldsApiName = RE_DataBaseQueryFields.sPopulatelatAndLongLocationQuery;
            String sWhereClause = RE_DataBaseQueryFields.sPopulatelatAndLongLocationWhereClause;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocationObjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    objdata = RE_PopulateLatAndLong.calloutHttpMethod((Location__c)sObj,zipCode);//[Anuj] changes made corresponding to One View 1359
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_PopulateLocationLatAndLong','populate','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                } 
            }
        }
        return objdata;
    }
}