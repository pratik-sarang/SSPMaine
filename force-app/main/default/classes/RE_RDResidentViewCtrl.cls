/**************************************************************************************************
* Class Name    : RE_RDResidentViewCtrl
* Owner         : Sai Kiran Velpula
* Created Date  : 07/02/2019
* Description   : Resource controller class for fetching resource detail of Resident View
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/
public with sharing class RE_RDResidentViewCtrl {
    private static Location zipCodeLocation= new Location();
    @AuraEnabled
    public static RE_CreateLightningServerResponse getResourceData(String strResourceRecId, String strLocationID, String strZipcode) {
        
        String resourceRecId = String.escapeSingleQuotes(strResourceRecId);
        String slocationID ;
        if(strLocationID != null){
            slocationID = String.escapeSingleQuotes(strLocationID);
        }
        else{
            slocationID=null;
        }               
        String zipcode = String.escapeSingleQuotes(strZipcode);
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sQuery;
        String switchCaseKey;
        Double dMiles;
        List<Resource__c> lstResources;
        String sResourceQuery;
        String sFieldsApiName;
        String sWhereClause;
        String sContactId;
        Boolean isFavorite = false;
        Set<String> sLocationResId = new Set<String>();
        Boolean checkDisableConnect = false;
        try{
            
            //Query to get the LocationResource details of Respective Resource Object
            List<LocationResource__c> lstLocationResource;
            set<String> setResourcesIds = new set<String>();
            List<LocationResource__c> lstAllLocations = new List<LocationResource__c>();
            set<String> setLocIds = new set<String>();
            LocationResource__c objSelectedLoc;
            //SOQL injection  
            lstLocationResource = fetchLocResource(slocationID, resourceRecId);
            String loggedInUserContactId = RE_GlobalConstants.sEmptyString;
            String strContactId ;
            if(UserInfo.getUserType() != 'Guest'){
                strContactId=GeneralUtility.getLoggedInUserContactId();// PMD fix - Suresh
            }   
            for(LocationResource__c objLocRes : lstLocationResource){
                //Force Reviewer Changes - Payal Dubela - 08/27
                if(slocationID != null && objLocRes.Location__c == slocationID){
                        setResourcesIds.add(objLocRes.Resource__c); // Other Related resources for Selected Location.
                }                 
                //RE Security Changes -391620 -Payal Dubela             
                /*else{
                    setResourcesIds.add(resourceRecId); // Other Related resources for Selected Location.
                    objSelectedLoc = objLocRes;
                }*/
                if(objLocRes.Resource__c == resourceRecId){
                    lstAllLocations.add(objLocRes);
                    setLocIds.add(objLocRes.Location__c);
                }
                if(slocationID != null && objLocRes.Location__c == slocationID && objLocRes.Resource__c == resourceRecId){
                    //if(objLocRes.Location__c == slocationID && objLocRes.Resource__c == resourceRecId){
                        objSelectedLoc = objLocRes;
                        if(UserInfo.getUserType() != 'Guest'){
                            loggedInUserContactId = strContactId;// PMD fix - Suresh
                            sLocationResId.add(objLocRes.Id);
                            //isFavorite = getFavoriteCheck(objLocRes.Id,loggedInUserContactId);
                        }
                        setLocIds.add(slocationID);
                   // }
                }
            }
            if(!sLocationResId.isEmpty()){
                isFavorite = getFavoriteCheck(sLocationResId,loggedInUserContactId);
            }
            // Resources Query
            lstResources = fetchResourceData(setResourcesIds);

            Resource__c objSelectedRes;
            Boolean isdsabldCnctSelectedRes = false;
            List<OtherResourceWrapper> lstChildWrap = new List<OtherResourceWrapper>();
            for(Resource__c objResource : lstResources){
                if(objResource.id != resourceRecId){ 
                    OtherResourceWrapper objChildWrap ;
                    if(objResource.Referrals__r != null && !objResource.Referrals__r.isEmpty()){
                        objChildWrap = new OtherResourceWrapper(true,objResource);
                        lstChildWrap.add(objChildWrap);
                        // mapResourcesVsConnectCheck.put(objResource,true);
                    }
                    else{
                        objChildWrap = new OtherResourceWrapper(false,objResource);
                        lstChildWrap.add(objChildWrap);
                    }
                }
                else{
                    objSelectedRes = objResource;
                    List<Referral__c> listOfReferrals = objSelectedRes.Referrals__r;
                    Set<Id> listOfRefLocIds = new Set<Id>();
                    if(listOfReferrals.size()>0 && !listOfReferrals.isEmpty())
                    {
                        for(Referral__c objReferral : listOfReferrals)
                        {
                        	listOfRefLocIds.add(objReferral.Location__c);
                        }
                    }
                    if(listOfRefLocIds.size()>0 && !listOfRefLocIds.isEmpty()){
                        for(Id locId : listOfRefLocIds)
                        {
                            if(locId != slocationID)
                            {
                                isdsabldCnctSelectedRes = objResource.Referrals__r != null && !objResource.Referrals__r.isEmpty() ? false : true;
                            }else
                            {
                                isdsabldCnctSelectedRes = objResource.Referrals__r != null && !objResource.Referrals__r.isEmpty() ? true : false;
                            }
                        }
                    }
                }
            }
            Location__c locRec;
            List<Location__c> lstLocations;
            List<Location__c> slstLocations;
            slstLocations = fetchLocationsData(setLocIds);
            Map<Id,Location__c> mapIdvsLocations = new Map<Id,Location__c>(slstLocations);
            //Force Reviewer Changes - Payal Dubela -08/27
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyLocation = (slocationID != null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyLocation) {
             when SWITCH_SUCCESS {  
                for(Id locId : mapIdvsLocations.keyset()){                    
                    if(locId == slocationID){
                        locRec = mapIdvsLocations.get(locId);
                    }                                    
                }
            }
            when SWITCH_FAILURE { 
                if(slstLocations!=null && slstLocations.size()>0){
                    locRec=mapIdvsLocations.get(objSelectedLoc.Location__c);
                }
            }
           }
            lstLocations = mapIdvsLocations.values();
            ResourceDetailsWrapper wrapObj = new ResourceDetailsWrapper();
            wrapObj.selectedResource = objSelectedRes;
            wrapObj.selectedlocationWrap = locRec;
            wrapObj.lstlocationWrap = lstLocations;
            wrapObj.lstOtherResourcesWrap = lstChildWrap;
            wrapObj.isdsabldCnctSelectedRes = isdsabldCnctSelectedRes;
            
            LocationTimeFields sLocTimeFields = new LocationTimeFields(locRec,objSelectedLoc);
            wrapObj.LocationTimeFields = sLocTimeFields;
            LocResourceWrapper sLocResFields = new LocResourceWrapper(objSelectedLoc);
            if(sLocTimeFields.displayLocResNotes == true){
                sLocResFields.Notes = objSelectedLoc.Notes__c;
            }
            if(sLocTimeFields.displayLocNotes == true){
                sLocResFields.Notes = locRec.Notes__c;
            }
            wrapObj.LocResourceWrapper = sLocResFields;
         
            Location geoLocationData;
            if(objSelectedLoc !=null){
                geoLocationData = objSelectedLoc.Location__r.Geolocation__c;
            }
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyProfile = (UserInfo.getUserType() != 'Guest')? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            //Force Reviewer Changes - Payal Dubela -08/27
            switch on (switchCaseKeyProfile) {
             when SWITCH_SUCCESS {              
                sContactId = GeneralUtility.getLoggedInUserContactId();
                String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
                //Added By Kojashree --- SSP Merge Fixes
                String sRole = GeneralUtility.getLoggedInUserSelectedRole();
               // Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sProfileName);
               Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sRole);
                if (objContact.ContactGeoLocation__c != null){
                    //dmiles = milesCalculation(objContact.ContactGeoLocation__c, geoLocationData);
                    dmiles = RE_MyPlanHelper.getDistance(objContact.ContactGeoLocation__c, geoLocationData, 'mi');
                }else if(zipCode != NULL && zipCode != 'undefined'){//Force Reviwer Fix - Suresh
                    dmiles = milesCalculation(zipCode, geoLocationData);
                    
                }
                mapResponse.put('usrLocation', JSON.serialize(objContact));
            }
            when SWITCH_FAILURE { 
                if(zipCode != 'undefined' || zipCode != NULL ){
                    dmiles = milesCalculation(zipCode, geoLocationData);
                }
             } 
           }  
            RE_CreateLightningServerResponse filesList = getFiles(slocationID);
            bSuccess = true;
            
            mapResponse.put('dMiles', dMiles);
            mapResponse.put('listOfFiles', filesList.objectData);
            if(geoLocationData != NULL){
               mapResponse.put('geoLocation', geoLocationData.getLatitude() + '##' + geoLocationData.getLongitude()); 
            }
            
            mapResponse.put('objWrapper', wrapObj);
            mapResponse.put('zipCodeLocation', zipCodeLocation.getLatitude() + '##' + zipCodeLocation.getLongitude());
            mapResponse.put('isfavorite', isFavorite); 
            if(objSelectedLoc!=null){
                mapResponse.put('locresourceId', objSelectedLoc.Id);
            }            
        }catch(Exception e){
            bSuccess = false;
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RDResidentViewCtrl', 'insertReferralForResident', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse getLoggedInUserRole(){
        Boolean bSuccess = false;
        Boolean bIsCPUserProfile = false;
        Boolean bIsResident = false;
        Boolean bIsResidentorGuest = false;
        Boolean bIsGuestUser = false;
        Boolean bIsAgencyUserProfile = false; //RE_Release 1.1 - Agency user capture- Mohan
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try{
                    String sRole;
                    Profile sProfile = GeneralUtility.getLoggedInUserProfile();
                    // Added By Kojashree -- SSP Merge Fixes
                    String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();

                    if(sProfile.Name == RE_GlobalConstants.strGuestProfileName){
                        bIsGuestUser=true;
                    }
                    else{
                     sRole   = GeneralUtility.getLoggedInUserContactRole();
                       /* if(sProfile.Name == RE_GlobalConstants.strCommunityProfileName || sProfile.Name == RE_GlobalConstants.RE_ASSISTER_PROFILE){ // need to add check for Assister profile as well
                            bIsCPUserProfile = true;
                        }
                        // added by Pankaj as part of ONEVIEW-1531
                        if(sProfile.Name == RE_GlobalConstants.strCitizenProfileName ){
                            bIsResidentorGuest = true;
                        }
                        if(sProfile.Name == RE_GlobalConstants.strAgencyProfileName ){
                            bIsAgencyUserProfile = true;
                        }*/
                        if(selectedRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || selectedRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF || selectedRole == RE_GlobalConstants.RE_ASSISTER_ROLE){ // need to add check for Assister profile as well
                            bIsCPUserProfile = true;
                        }
                         if(selectedRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL ){
                            bIsResidentorGuest = true;
                        }
                        if(selectedRole == RE_GlobalConstants.CASE_WORKER || selectedRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR){
                            bIsAgencyUserProfile = true;
                        }
                    }
                    ID userid=UserInfo.getUserId();
                    //Removing for perf issue (Payal)
                    /* String sFieldsToQueryOnperm = RE_DataBaseQueryFields.sFieldsToQueryOnperm;
String sWhereClauseOnperm = RE_DataBaseQueryFields.sWhereClauseOnperm;
String sPermissionSetQuery;

                    Map<String,String> mappermQueryParameters = new Map<String,String>();
                    mappermQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnperm);
                    mappermQueryParameters.put(RE_GlobalConstants.sLimitKey,Label.maxsoqlquerylimit);
                    sPermissionSetQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sPermissionSetObj, sFieldsToQueryOnperm, mappermQueryParameters); 
                    
                    List<PermissionSetAssignment> lstPermissionSet = Database.query(sPermissionSetQuery);
                   
                    for(PermissionSetAssignment pmset : lstPermissionSet){ */
                        // removing this as part of ONEVIEW-1531
                        /*if(pmset.PermissionSet.Name==RE_GlobalConstants.RESIDENT_PERMISSIONSET_NAME){
                            bIsResidentorGuest=true;
                        }*/
                       
                        
                    //}

                    mapResponse.put('bIsCPUserProfile', bIsCPUserProfile);
                    mapResponse.put('bIsGuestUser', bIsGuestUser);
                    mapResponse.put('bIsResidentorGuest', bIsResidentorGuest);
                    mapResponse.put('bIsAgencyUserProfile', bIsAgencyUserProfile);//RE_Release 1.1 - Agency user capture- Mohan
                    bSuccess =  true;
                }catch(Exception e){
                    errorMap.put('error',e.getMessage()); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RDResidentViewCtrl', 'getLoggedInUserRole', e.getMessage(), true);}
        

        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
   /********************************************************************************************
    * @author       Sai
    * @date         09/03/2019
    * @methodname   insertReferralForResident()
    * @description  Insert referral recoerd
    * @param        {Resource__c,String,Boolean}
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/ 
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReferralForResident(Resource__c objResource, String strlocationID, Boolean bConsentAgreed){
        String slocationID ;
	GeneralUtility.isAuthenticatedUser();

        if(strLocationID != null){
            slocationID = String.escapeSingleQuotes(strLocationID);
        }
        else{
            slocationID=null;
        }        
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Boolean> mapResponse = new Map<String, Boolean>{};
                List<Referral__c> referrallst = new List<Referral__c>();  
        try{
            Referral__c objReferral= new Referral__c();
            if( objResource.Organization__r.IsClaimed__c && objResource.Organization__r.Status__c==RE_GlobalConstants.sAccountStatus){
                objReferral.Status__c= RE_GlobalConstants.STATUS_NEW;
            }
            else if(!objResource.Organization__r.IsClaimed__c){
                //objReferral.Status__c= 'In Progress - Org Not in System';
                objReferral.Status__c=RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
            } 
            Id contactId = GeneralUtility.getLoggedInUserContactId();
            objReferral.Contacts__c = contactId;
            objReferral.Location__c = slocationID;
            objReferral.Resource__c = objResource.Id;
            objReferral.ReferredAccountID__c = objResource.Organization__c;            
            ID loggedinuserID = UserInfo.getUserId();
            objReferral.OwnerId=loggedinuserID;
            objReferral.DateOfReferral__c=Date.today();
            //Added source
            objReferral.Source__c= RE_GlobalConstants.ADDED_BY_RESIDENT;
            
            RE_SharingByPassCtrl.insertReferral(objReferral);
            
            if(bConsentAgreed){
                Account objAccount = new Account();
                objAccount.Id = GeneralUtility.getLoggedInUserAccountId();
                objAccount.HasOptedOutOfAccount__c = false;
                RE_SharingByPassCtrl.updateSobject(objAccount.getSobjectType(), objAccount);
            }
            bSuccess = true;
            
        }catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RDResidentViewCtrl', 'insertReferralForResident', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         03/09/2019
    * @methodname   getAllLocations()
    * @description  Fetching all resource location based on Resource Id
    * @param        String 
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/ 
    @AuraEnabled
    public static RE_CreateLightningServerResponse getAllLocations(String strResourceID){
        
        String sResourceID = String.escapeSingleQuotes(strResourceID);
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};               
                set<String> setLocIds = new set<String>();
        List<LocationResource__c> lstLocationResource;
        
        try{
            lstLocationResource = fetchAllLocationDataOnLR(sResourceID);
            for(LocationResource__c locRes : lstLocationResource){
                setLocIds.add(locRes.Location__c);
            }
            List<Location__c> slocations = fetchLocationAddressFields(setLocIds);
            bSuccess=true;
            mapResponse.put('allLocations',slocations);

        }catch(Exception e){
            errorMap.put('error',e.getMessage()); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RDResidentViewCtrl', 'insertReferralForResident', e.getMessage(), true); }
     
         
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
        
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         19/08/2019
    * @methodname   getFavoriteCheck()
    * @description  Fetching favorite Check 
    * @param        Location ResourceId, Logged In user contactID
    * @return      Boolean
    **********************************************************************************************/ 

    public static Boolean getFavoriteCheck(Set<String> sLocationResId, String sContactId){
        
        Boolean bIsFav = false;
        String sFieldNames = RE_DataBaseQueryFields.FIELDS_DELETE_FAVORITES;
        Map<String, String> mapQueryParameters= new Map<String, String>();
         
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.WHERE_CLAUSE_DELETE_FAVORITESMYFVRTS);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, RE_DataBaseQueryFields.sLimit);
        Id sFavRecordTypeId=Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Resource Favorite').getRecordTypeId();
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Favorite__c', sFieldNames, mapQueryParameters);
        if(!sLocationResId.isEmpty() && String.isNotBlank(sContactId)){
            List<Favorite__c> lstFavs = Database.query(sQuery); 
            
            if(!lstFavs.isEmpty()){
                bIsFav = true;  
            }
           
        }
        
        return bIsFav;
    }
    
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         08/19/2019
    * @methodname   getOptOutInfoSharingDetails()
    * @description  This methods is used to get OptOutInfoSharing Information from Account
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getOptOutInfoSharingDetails(){
        return RE_MyPlanCtrl.getOptOutInfoSharingDetails();
    }
    
    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         08/19/2019
    * @methodname   connectDraftReferralsFromResourceDetails()
    * @description  This methods is used to connect Draft Referrals
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse connectDraftReferralsFromResourceDetails(String strReferralId, Boolean bConsentAgreed){
        
        String sReferralId = String.escapeSingleQuotes(strReferralId);
        return RE_MyPlanCtrl.connectDraftReferrals(sReferralId, bConsentAgreed);
    }
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse createFavorite(String strLocationResId){
        return RE_SharingByPassCtrl.createFavorite(String.escapeSingleQuotes(strLocationResId));
    }
    
   /********************************************************************************************
    * @author       Sai
    * @date         06/07/2019
    * @methodname   milesCalculation()
    * @description  This methods is used to get the miles distance between user location and resource
    * @return       Double
    **********************************************************************************************/
    public static Double milesCalculation(String sZipcode, Location geoLocationData){
        Double dMiles;
        HttpResponse response = getZipCodeLatLong(sZipcode);
        RE_GoogleMapGeoLocationResponseWrapper wrapper = (RE_GoogleMapGeoLocationResponseWrapper) JSON.deserialize(response.getBody(), RE_GoogleMapGeoLocationResponseWrapper.class);        
        RE_GoogleMapGeoLocationResponseWrapper.Northeast loc;
        if(wrapper.status == 'OK'){
            for(RE_GoogleMapGeoLocationResponseWrapper.Results r: wrapper.results){
                loc = new RE_GoogleMapGeoLocationResponseWrapper.Northeast();
                loc.lat = r.geometry.location.lat;
                loc.lng = r.geometry.location.lng;
                zipCodeLocation = Location.newInstance(loc.lat, loc.lng);
            }
        }else{
            zipCodeLocation = Location.newInstance(null, null);
        }
        dMiles = RE_MyPlanHelper.getDistance(zipCodeLocation, geoLocationData, 'mi');
        return dMiles;
    }
    /********************************************************************************************
    * @author       Pankaj
    * @date         09/03/2019
    * @methodname   getZipCodeLatLong()
    * @description  Helper method for getting Lat/Long based on user zipcode
    * @return       HttpResponse
    **********************************************************************************************/
    public static HttpResponse getZipCodeLatLong(String sZipcode){
        Http http = new Http(); 
        HttpRequest request = new HttpRequest();
        String encodedZip=EncodingUtil.urlEncode(sZipcode,'UTF-8');
        string strKey =Google_Map_API__c.getOrgDefaults().Key_Value__c;
        request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+encodedZip+',&key='+strKey);
        request.setMethod('GET');
        HttpResponse response;
        if(!Test.isRunningTest()){
            response = http.send(request);
        }
        else{
            response=RE_GoogleMapAPIMockResponse.respond(request);
        }
        return response;
    }
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocResource()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/ 
    public static List<LocationResource__c> fetchLocResource(String slocationID, String resourceRecId){
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        List<LocationResource__c> lstLocationResource;
        String sLocationResourceQuery;
        String sFieldsApiName;
        String sWhereClause;
        String switchCaseKey;
        sFieldsApiName = RE_DataBaseQueryFields.sQueryLocFieldsRDResidentViewCtrl;
        sWhereClause = RE_DataBaseQueryFields.sWhereClauseLocRDResidentViewCtrl;
        
        //sWhereClause  = 'Location__c =: String.escapeSingleQuotes(slocationID) OR Resource__c =: String.escapeSingleQuotes(resourceRecId) ';
        
        List<LocationResource__c> lstAllLocations = new List<LocationResource__c>();
        LocationResource__c objSelectedLoc;// = new LocationResource__c();
        set<String> setLocIds = new set<String>();
        
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsApiName,mapQueryParameters);
        set<String> setResourcesIds = new set<String>();
        switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKey) {
            when 'success' {
                sLocationResourceQuery =  mapResponseData.get(true);
                
                if(slocationID!=null){
                    lstLocationResource = RE_SharingByPassCtrl.fetchLocResource(sLocationResourceQuery,String.escapeSingleQuotes(slocationID),String.escapeSingleQuotes(resourceRecId));
                } else{
                    lstLocationResource = RE_SharingByPassCtrl.fetchLocResource(sLocationResourceQuery,null,String.escapeSingleQuotes(resourceRecId));
                }                
            }
        }
        return lstLocationResource;
    }
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocationsData()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/ 
    public static List<Location__c> fetchLocationsData(Set<String> setLocIds){
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sLocQuery;
        String sFieldsApiName;
        String sWhereClause;
        String switchCaseKey;
        
        List<Location__c> slstLocations;
        sFieldsApiName = RE_DataBaseQueryFields.sQueryLocationFieldsRDResidentViewCtrl;
        sWhereClause = RE_DataBaseQueryFields.sWhereClauseLocationFieldsRDResidentViewCtrl;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Location__c', sFieldsApiName, mapQueryParameters);
        switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKey) {
            when 'success' {
                sLocQuery =  mapResponseData.get(true);
                slstLocations = RE_SharingByPassCtrl.fetchLocationsData(sLocQuery,setLocIds);
                
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RDResidentViewCtrl','getWrapper','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        
        return slstLocations;
    }
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchAllLocationDataOnLR()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/
    public static List<LocationResource__c> fetchAllLocationDataOnLR(String sResourceID){
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Set<Id> locationIds = new Set<Id>();
        
        String sQuery;
        String switchCaseKey;
        String sFieldsApiName;
        String sWhereClause;
        
        List<LocationResource__c> lstLocationResource;
        String sLocationResourceQuery;
        sFieldsApiName = RE_DataBaseQueryFields.sQueryLocFieldsRDResidentViewCtrl;
        sWhereClause = RE_DataBaseQueryFields.sWhereClauseAllLocRDResidentViewCtrl;
        
        List<LocationResource__c> lstAllLocations = new List<LocationResource__c>();
        LocationResource__c objSelectedLoc;// = new LocationResource__c();
        set<String> setLocIds = new set<String>();
        
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsApiName,mapQueryParameters);
        set<String> setResourcesIds = new set<String>();
        switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKey) {
            when 'success' {
                sLocationResourceQuery =  mapResponseData.get(true);
                
                lstLocationResource = RE_SharingByPassCtrl.fetchAllLocationDataOnLR(sLocationResourceQuery,String.escapeSingleQuotes(sResourceID));
            }
            
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RDResidentViewCtrl','getAllLocations','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        } 
        return lstLocationResource;
    }
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocationsAddressFields()
    * @description  This function is use to get the Location Address Fields based on location Id.
    * @param        setLocIds
    * @return       List<Location__c>
    **********************************************************************************************/ 
    public static List<Location__c> fetchLocationAddressFields(Set<String> setLocIds){
        List<Location__c> slocations;
        String switchCaseKey;
        String sFieldsApiName;
        String sWhereClause;
        String sLocationQuery;
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        sFieldsApiName = RE_DataBaseQueryFields.sQueryLocAddressFieldsRDResidentViewCtrl;
        sWhereClause = RE_DataBaseQueryFields.sWhereClauseLocAddressRDResidentViewCtrl;
        
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Location__c',sFieldsApiName,mapQueryParameters);
        set<String> setResourcesIds = new set<String>();
        switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKey) {
            when 'success' {
                sLocationQuery = mapResponseData.get(true);                
                slocations = RE_SharingByPassCtrl.fetchLocationAddressFields(sLocationQuery, setLocIds);
            }            
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RDResidentViewCtrl','getAllLocations','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        return slocations;        
    }
    
    /* ******************************************************************************************
    * @author       Suyash Singhal
    * @date         16/08/2019
    * @methodname   getFiles- Without Sharing
    * @description  This methods is used to get files without sharing on Resource Details Page
    * @param        Location Record Id
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/    
        public static RE_CreateLightningServerResponse getFiles(String sParentId){
        Map<String, Object> mapResult = new Map<String, Object>();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Id sDocumentRecordType = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('DocumentDetail__c','RE_Documents');
        String sDcoDetailsFields = RE_DataBaseQueryFields.strsDcoDetailsFields;
        String sDocDetailWhereClause = RE_DataBaseQueryFields.sDocDetailWhereClauseWithoutSharingMethod;
        Map<String,String> mapQueryParameters = new Map<String,String>();
        List<ContentDocument> lstConDocs = new List<ContentDocument>(); 
        Map<String,String> mapQueryParametersDocDetail = new Map<String,String>();
        mapQueryParametersDocDetail.put(RE_GlobalConstants.sWhereClauseKey, sDocDetailWhereClause);
        mapQueryParametersDocDetail.put(RE_GlobalConstants.sLimitKey, '500');
        String sQueryDoc;
        Map<String,String> mapFileIDVsDocTypes = new Map<String,String>();
        Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strDocumentAPIame,sDcoDetailsFields,mapQueryParametersDocDetail);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                   
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sQueryDoc =  mapResponse.get(true);
                List<DocumentDetail__c> doclist=RE_SharingByPassCtrl.getDocumentDetails(sParentId,sQueryDoc,sDocumentRecordType);
                //sParentId
                //
                for(DocumentDetail__c objDocDet : doclist){
                    mapFileIDVsDocTypes.put(objDocDet.FileId__c,objDocDet.DocumentType__c);
                }
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','getLocationDetails','Some Fields doesn\'t have the required access :: '+mapResponse.get(false), true);
            }
        }
        
        Set<String> lstConDocIds = mapFileIDVsDocTypes.keySet();
        String sFieldsApiName = RE_DataBaseQueryFields.sQueryRE_CreateLightningServerResponse;
        String sWhereClause = RE_DataBaseQueryFields.strWhereClauseOnLocationCtrl_RE_CreateLightningServerResponse;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '500');
        
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strContentDocument,sFieldsApiName,mapQueryParameters);
        lstConDocs=RE_SharingByPassCtrl.getContentDocument(lstConDocIds,sQuery);
        //Abhijeet-code start
        //List<ContentVersion> lstContentVersion = new List<ContentVersion>();
        Map<String,String> mapContentVersionContentId = new Map<String,String>();
        Map<String,String> mapContentDocumentDistributionURL = new Map<String,String>();
        for(ContentDocument cntVrsn : lstConDocs){	
            mapContentVersionContentId.put(cntVrsn.LatestPublishedVersionId,cntVrsn.Id);	
        }
        //Added by Anuj "ContentVersion.getSObjectType().getDescribe().isAccessible()" check in below condition regarding Force Reviewer comments   
        /*if(ContentVersion.getSObjectType().getDescribe().isAccessible() && Schema.sObjectType.contentversion.fields.Id.isAccessible() && Schema.sObjectType.contentversion.fields.ContentdocumentId.isAccessible() && lstConDocIds!=null ){
                    lstContentVersion = [SELECT Id,ContentdocumentId FROM contentversion where ContentdocumentId In: lstConDocIds];
        }
        for(ContentVersion cntVrsn : lstContentVersion){
            mapContentVersionContentId.put(cntVrsn.Id,cntVrsn.ContentdocumentId);
        }*/
        List<contentdistribution> lstContentDistribution;
      //  if(Schema.sObjectType.contentdistribution.fields.Id.isAccessible()&& Schema.sObjectType.contentdistribution.fields.ContentversionId.isAccessible() && Schema.sObjectType.contentdistribution.fields.DistributionPublicUrl.isAccessible()){
            lstContentDistribution = RE_SharingByPassCtrl.getContentdistribution(mapContentVersionContentId);
                //[SELECT Id,ContentversionId,DistributionPublicUrl FROM contentdistribution where ContentversionId IN: mapContentVersionContentId.keySet()];
      //  }
        
        for(contentdistribution contDst : lstContentDistribution){
            mapContentDocumentDistributionURL.put(mapContentVersionContentId.get(contDst.ContentversionId),contDst.DistributionPublicUrl);
        }
        //Abhijeet-code end
        List<RE_LocationCtrl.fileWrapper> lstFileWrapper = new List<RE_LocationCtrl.fileWrapper>();
        for(ContentDocument objConDoc  : lstConDocs){
            if(mapFileIDVsDocTypes.get(objConDoc.Id) != null ){
                RE_LocationCtrl.fileWrapper objWrapper = new RE_LocationCtrl.fileWrapper(objConDoc,mapFileIDVsDocTypes.get(objConDoc.Id),mapContentDocumentDistributionURL.get(objConDoc.Id));
                lstFileWrapper.add(objWrapper);
            }
        }
        
        bSuccess = true;
        mapResult.put('lstFileWrapper', lstFileWrapper);
        mapResult.put('lstConDocs', lstConDocs);
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResult); 
    }
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocResource()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<Resource__c> fetchResourceData(Set<String> setResourcesIds){
       /* Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<String, object> mapInputs = new Map<String, object>();
        
        String sResourceQuery;
        String sFieldsApiName;
        String sWhereClause;
        String switchCaseKey;
        String sWhereClauseReferral;
        Id contactId;
        List<Resource__c> lstResources;
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
            sWhereClauseReferral = RE_DataBaseQueryFields.WHERE_CLAUSE_guestReferral;
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
            sResourceQuery =  lstQuertStringSpilt[0] +',('+ String.escapeSingleQuotes(sChildReferralQuery) + ') FROM'  + lstQuertStringSpilt[1]; 
        }
        //lstResources = Database.query(sResourceQuery); 
        mapInputs.put('setResourcesIds',setResourcesIds);
        mapInputs.put('sClosed',sClosed);
        mapInputs.put('sResourceQuery',sResourceQuery);
        mapInputs.put('sAccountStatus',sAccountStatus);
        mapInputs.put('contactId',contactId);
        lstResources = RE_SharingByPassCtrl.fetchResourceData(mapInputs);
        
        return lstResources;*/
        return RE_ResourceCtrl.fetchResourceData(setResourcesIds);
    }
    
   /********************************************************************************************
    * @author       Sai
    * @date         09/03/2019
    * @classname    ResourceDetailsWrapper
    * @description  Wrapper class for Resource detail
    **********************************************************************************************/
    public class ResourceDetailsWrapper{
        @AuraEnabled public Resource__c selectedResource; 
        @AuraEnabled public Boolean isdsabldCnctSelectedRes;
        @AuraEnabled public Location__c selectedlocationWrap;
        @AuraEnabled public List<Location__c> lstlocationWrap; 
        @AuraEnabled public List<OtherResourceWrapper> lstOtherResourcesWrap;
        @AuraEnabled public Object LocationTimeFields;
        @AuraEnabled public Object LocResourceWrapper;//Nandita: Added for Data model Changes
    }
    public class LocResourceWrapper{
         //@AuraEnabled public LocationResource__c selectedLocResourceWrap;
         @AuraEnabled public String NextSteps;
         @AuraEnabled public String TollFree;
         @AuraEnabled public String Notes;
         @AuraEnabled Public String Fees;
         @AuraEnabled Public String WhatToBring;
         @AuraEnabled Public String Qualifications;
         @AuraEnabled Public String IncomeEligibility;
         @AuraEnabled Public String Benefitting;
         @AuraEnabled Public String GeographyServed;
         @AuraEnabled Public String FirstPOCName;
         @AuraEnabled Public String FirstPOCEmail;
         @AuraEnabled Public String FirstPOCPhone;
         @AuraEnabled Public String SecondPOCName;
         @AuraEnabled Public String SecondPOCEmail;
         @AuraEnabled Public String SecondPOCPhone;
         @AuraEnabled Public String MainPhone;
         @AuraEnabled Public String Description;
         @AuraEnabled public String AgesServed;
         public LocResourceWrapper(LocationResource__c objLocRes){
             NextSteps = objLocRes.NextSteps__c;
             TollFree = objLocRes.TollFree__c;
             Notes = '';//objLocRes.Notes__c;
             Fees = objLocRes.Fees__c;
             WhatToBring = objLocRes.WhatToBring__c;
             Qualifications = objLocRes.EligibilityDescription__c;
             IncomeEligibility = objLocRes.IncomeEligibility__c;
             Benefitting = objLocRes.Benefits__c;
             GeographyServed = objLocRes.Geography_Served__c;
             FirstPOCName = objLocRes.FirstPointOfContactName__c;
             FirstPOCEmail = objLocRes.FirstPointofContactEmail__c;
             FirstPOCPhone = objLocRes.FirstPointofContactPhone__c;
             SecondPOCName = objLocRes.SecondPointOfContactName__c;
             SecondPOCEmail = objLocRes.SecondPointofContactEmail__c;
             SecondPOCPhone = objLocRes.SecondPointofContactPhone__c;
             MainPhone = objLocRes.Phone__c;
             Description = objLocRes.ResourceDescription__c;
             AgesServed = objLocRes.AgesServed__c;
         }
    }
    /********************************************************************************************
    * @author       Suyash
    * @date         09/03/2019
    * @classname    OtherResourceWrapper
    * @description  Wrapper class for Other Resource details
    **********************************************************************************************/
    public class OtherResourceWrapper{
        @AuraEnabled public Boolean isdisabledConnect; 
        @AuraEnabled public Boolean isDisabled = false; 
        @AuraEnabled public Resource__c objResource; 
        public OtherResourceWrapper(Boolean isdisabledConnect,Resource__c objResource){
            this.isdisabledConnect = isdisabledConnect;
            this.objResource = objResource;
        }
    }
    /********************************************************************************************
    * @author       Suyash
    * @date         09/03/2019
    * @classname    LocationTimeFields
    * @description  Wrapper class for Resource Location Operating Hours
    **********************************************************************************************/
    public class LocationTimeFields{
        @AuraEnabled public String MondayOpen; 
        @AuraEnabled public String MondayClose; 
        @AuraEnabled public String TuesdayOpen;
        @AuraEnabled public String TuesdayClose; 
        @AuraEnabled public String WednesdayOpen; 
        @AuraEnabled public String WednesdayClose;
        @AuraEnabled public String ThursdayOpen; 
        @AuraEnabled public String ThursdayClose; 
        @AuraEnabled public String FridayOpen;
        @AuraEnabled public String FridayClose; 
        @AuraEnabled public String SaturdayOpen; 
        @AuraEnabled public String SaturdayClose;
        @AuraEnabled public String SundayOpen; 
        @AuraEnabled public String SundayClose;
        @AuraEnabled Public Boolean isMondayClosed = false;
        @AuraEnabled Public Boolean isTuesdayClosed= false;
        @AuraEnabled Public Boolean isWednesdayClosed= false;
        @AuraEnabled Public Boolean isThursdayClosed= false;
        @AuraEnabled Public Boolean isFridayClosed= false;
        @AuraEnabled Public Boolean isSaturdayClosed= false;
        @AuraEnabled Public Boolean isSundayClosed= false;
         @AuraEnabled Public Boolean displayLocResNotes = false;//Nandita: 352685: Added logic to display location Resource notes in Referral email
        @AuraEnabled Public Boolean displayLocNotes = false;//Nandita: 352685: Added variable to display location notes in Referral email
        
        Public LocationTimeFields(Location__c sLocation, LocationResource__c sObjLocResource){
            DateTime dTime; 
            map<String,List<String>> sLocOperationMap = GeneralUtility.getLocationOperationHours (sLocation,sObjLocResource);
            String switchCaseKey;
            //Force Reviewer Changes - Payal Dubela - 08/27
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyLocOp = (sLocOperationMap != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                   
            switch on (switchCaseKeyLocOp) {
              when SWITCH_SUCCESS {
                //Nandita: 352685: Added logic to display location notes in Referral email
                switchCaseKey = sObjLocResource.Notes__c == null? 'TRUE':'FALSE';
               // if(sObjLocResource.Notes__c == null){
                switch on (switchCaseKey) {
                    when 'TRUE'{  
                    if(sLocOperationMap.get('Monday')[2] == 'true'){
                        isMondayClosed = true;  displayLocNotes = false;
                    }
                    else if((sLocOperationMap.get('Monday')[0]!='' && sLocOperationMap.get('Monday')[0] != null)
                    && (sLocOperationMap.get('Monday')[1]!='' && sLocOperationMap.get('Monday')[1] != null))
                    {
                        MondayOpen =  sLocOperationMap.get('Monday')[0];
                        MondayClose = sLocOperationMap.get('Monday')[1];
                        displayLocNotes = false;
                    }
                    else
                    {
                        displayLocNotes = true;MondayOpen='';MondayClose='';
                    }
                    //Tuesday
                    if(sLocOperationMap.get('Tuesday')[2] == 'true'){
                        isTuesdayClosed = true; displayLocNotes = false;
                    }
                    else if((sLocOperationMap.get('Tuesday')[0]!='' && sLocOperationMap.get('Tuesday')[0] != null)
                    && (sLocOperationMap.get('Tuesday')[1]!='' && sLocOperationMap.get('Tuesday')[1] != null))
                    {
                        TuesdayOpen =  sLocOperationMap.get('Tuesday')[0];
                        TuesdayClose = sLocOperationMap.get('Tuesday')[1];
                        displayLocNotes = false;
                    }
                    else
                    {
                        displayLocNotes = true;TuesdayOpen='';TuesdayClose='';
                    }
                     //Wednesday   
                     if(sLocOperationMap.get('Wednesday')[2] == 'true'){
                        isWednesdayClosed = true; displayLocNotes = false;
                    }
                    else if((sLocOperationMap.get('Wednesday')[0]!='' && sLocOperationMap.get('Wednesday')[0] != null)
                    && (sLocOperationMap.get('Wednesday')[1]!='' && sLocOperationMap.get('Wednesday')[1] != null))
                    {
                        WednesdayOpen =  sLocOperationMap.get('Wednesday')[0];
                        WednesdayClose = sLocOperationMap.get('Wednesday')[1];
                        displayLocNotes = false;
                    }
                    else
                    {
                        displayLocNotes = true;WednesdayOpen='';WednesdayClose='';
                    }
                    //Thursday
                    if(sLocOperationMap.get('Thursday')[2] == 'true'){
                        isThursdayClosed = true;displayLocNotes = false;
                    }
                    else if((sLocOperationMap.get('Thursday')[0]!='' && sLocOperationMap.get('Thursday')[0] != null)
                    && (sLocOperationMap.get('Thursday')[1]!='' && sLocOperationMap.get('Thursday')[1] != null))
                    {
                        ThursdayOpen =  sLocOperationMap.get('Thursday')[0];
                        ThursdayClose = sLocOperationMap.get('Thursday')[1];
                        displayLocNotes = false;
                    }
                    else
                    {
                        displayLocNotes = true;ThursdayOpen='';ThursdayClose='';
                    }
                   //Friday   
                    if(sLocOperationMap.get('Friday')[2] == 'true'){
                        isFridayClosed = true; displayLocNotes = false;
                    }
                    else if((sLocOperationMap.get('Friday')[0]!='' && sLocOperationMap.get('Friday')[0] != null)
                    && (sLocOperationMap.get('Friday')[1]!='' && sLocOperationMap.get('Friday')[1] != null))
                    {
                        FridayOpen =  sLocOperationMap.get('Friday')[0];
                        FridayClose = sLocOperationMap.get('Friday')[1];
                        displayLocNotes = false;
                    }
                    else
                    {
                        displayLocNotes = true;FridayOpen='';FridayClose='';
                    }
                      //Saturday 
                    if(sLocOperationMap.get('Saturday')[2] == 'true'){
                        isSaturdayClosed = true; displayLocNotes = false;
                    }
                    else if((sLocOperationMap.get('Saturday')[0]!='' && sLocOperationMap.get('Saturday')[0] != null)
                    && (sLocOperationMap.get('Saturday')[1]!='' && sLocOperationMap.get('Saturday')[1] != null))
                    {
                        SaturdayOpen =  sLocOperationMap.get('Saturday')[0];
                        SaturdayClose = sLocOperationMap.get('Saturday')[1];
                        displayLocNotes = false;
                    }
                    else
                    {
                        displayLocNotes = true;SaturdayOpen='';SaturdayClose='';
                    }
                     //Sunday  
                    if(sLocOperationMap.get('Sunday')[2] == 'true'){
                        isSundayClosed = true; displayLocNotes = false;
                    }
                    else if((sLocOperationMap.get('Sunday')[0]!='' && sLocOperationMap.get('Sunday')[0] != null)
                    && (sLocOperationMap.get('Sunday')[1]!='' && sLocOperationMap.get('Sunday')[1] != null))
                    {
                        SundayOpen =  sLocOperationMap.get('Sunday')[0];
                        SundayClose = sLocOperationMap.get('Sunday')[1];
                        displayLocNotes = false;
                    }
                    else
                    {
                        displayLocNotes = true; SundayOpen = '';SundayClose='';
                    }
                        
                }
               // else{
                when 'FALSE'{
                     //Nandita: 352685: Added logic to display location Resource notes in Referral email
                        if( sLocOperationMap.get('Monday')[3] == 'true') {
                        MondayOpen =  sLocOperationMap.get('Monday')[3] == 'true' ?sLocOperationMap.get('Monday')[0]:'';
                        MondayClose = sLocOperationMap.get('Monday')[3] == 'true' ?sLocOperationMap.get('Monday')[1]:'';
                        isMondayClosed = sLocOperationMap.get('Monday')[2] == 'true'? true:false;
                        displayLocResNotes = false;
                        }
                        else{
                            displayLocResNotes = true; MondayOpen=''; MondayClose='';
                        }
                        if(sLocOperationMap.get('Tuesday')[3] == 'true'){
                        TuesdayOpen =  sLocOperationMap.get('Tuesday')[3] == 'true' ?sLocOperationMap.get('Tuesday')[0]:'';
                        TuesdayClose = sLocOperationMap.get('Tuesday')[3] == 'true' ?sLocOperationMap.get('Tuesday')[1]:'';
                        isTuesdayClosed = sLocOperationMap.get('Tuesday')[2] == 'true'? true:false;
                        displayLocResNotes = false;
                        }
                        else{
                           displayLocResNotes = true;TuesdayOpen='';TuesdayClose='';
                        }
                        if(sLocOperationMap.get('Wednesday')[3] == 'true'){
                        WednesdayOpen =  sLocOperationMap.get('Wednesday')[3] == 'true' ?sLocOperationMap.get('Wednesday')[0]:'';
                        WednesdayClose = sLocOperationMap.get('Wednesday')[3] == 'true' ?sLocOperationMap.get('Wednesday')[1]:'';
                        isWednesdayClosed = sLocOperationMap.get('Wednesday')[2] == 'true'? true:false;
                        displayLocResNotes = false;
                        }
                        else{
                           displayLocResNotes = true; WednesdayOpen = '';WednesdayClose = '';
                        }
                        if(sLocOperationMap.get('Thursday')[3] == 'true'){
                            ThursdayOpen =  sLocOperationMap.get('Thursday')[3] == 'true' ?sLocOperationMap.get('Thursday')[0]:'';
                            ThursdayClose = sLocOperationMap.get('Thursday')[3] == 'true' ?sLocOperationMap.get('Thursday')[1]:'';
                        isThursdayClosed = sLocOperationMap.get('Thursday')[2] == 'true'? true:false;
                        displayLocResNotes = false;
                        }else{
                           displayLocResNotes = true; ThursdayOpen =''; ThursdayClose = '';
                        }
                        if(sLocOperationMap.get('Friday')[3] == 'true'){
                        FridayOpen =  sLocOperationMap.get('Friday')[3] == 'true' ?sLocOperationMap.get('Friday')[0]:'';
                        FridayClose = sLocOperationMap.get('Friday')[3] == 'true' ?sLocOperationMap.get('Friday')[1]:'';
                        isFridayClosed = sLocOperationMap.get('Friday')[2] == 'true'? true:false;
                        displayLocResNotes = false;
                        }else{
                           displayLocResNotes = true;FridayOpen = ''; FridayClose = '';
                        }
                        if(sLocOperationMap.get('Saturday')[3] == 'true'){
                        SaturdayOpen =  sLocOperationMap.get('Saturday')[3] == 'true' ?sLocOperationMap.get('Saturday')[0]:'';
                        SaturdayClose = sLocOperationMap.get('Saturday')[3] == 'true' ?sLocOperationMap.get('Saturday')[1]:'';
                        isSaturdayClosed = sLocOperationMap.get('Saturday')[2] == 'true'? true:false;
                        displayLocResNotes = false;
                        }else{
                           displayLocResNotes = true;SaturdayOpen = ''; SaturdayClose = '';
                        }
                        if(sLocOperationMap.get('Sunday')[3] == 'true'){
                        SundayOpen =  sLocOperationMap.get('Sunday')[3] == 'true' ?sLocOperationMap.get('Sunday')[0]:'';
                        SundayClose = sLocOperationMap.get('Sunday')[3] == 'true' ?sLocOperationMap.get('Sunday')[1]:'';
                        isSundayClosed = sLocOperationMap.get('Sunday')[2] == 'true'? true:false;
                        displayLocResNotes = false;
                        }else{
                           displayLocResNotes = true;SundayOpen =''; SundayClose='';
                        }
                    }
                }//end switch
            }
          }// end if     
        }
            
    }
}