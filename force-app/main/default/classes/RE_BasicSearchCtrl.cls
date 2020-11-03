/**
* Class Name    : RE_BasicSearchCtrl
* Owner         : DELOITTE
* Created Date  : 07/17/2019
* Description   : Controller class for Basic Search
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/17/2019  Pankaj      Keyword Search
*  07/17/2019  Nupoor      Category Search
*  12/02/2019  Pankaj      Added logic for displaying resources with null values
**/
public with sharing class RE_BasicSearchCtrl {
    /********************************************************************************************
* @author       Nupoor
* @date         07/17/2019
* @methodname   getDomainCategories()
* @description  This methods is used to get the domain categories
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getDomainCategories(Boolean showByCategory){
        RE_CreateLightningServerResponse objResponse;
        try{
            objResponse = RE_ResourceCategoryCtrl.getResourceCategories(showByCategory);
        }catch(Exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_BasicSearchCtrl.class.getName(),'getDomainCategories', e.getMessage()+' '+e.getStackTraceString(), true);}
        return objResponse;
    }
    /********************************************************************************************
* @author       Nupoor
* @date         07/17/2019
* @methodname   getUserInfo()
* @description  This methods is used to get the loggedIn User Info
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getUserInfo(){
        RE_CreateLightningServerResponse objResponse;
        try{
            objResponse = RE_ArchetypeCtrl.processUserInfo('');
        }catch(Exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_BasicSearchCtrl.class.getName(),'getUserInfo', e.getMessage()+' '+e.getStackTraceString(), true);}
        return objResponse;
    }
    /********************************************************************************************
* @author       Pankaj
* @date         07/17/2019
* @methodname   insertReferralForResident()
* @description  This methods is used to insert a referral record for the Citizen
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReferralForResident(String objResource, String locationID, Boolean bConsentAgreed){
        //RE_Release 1.4 – Iron Dome Changes(07/14) - Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse objResponse;
        try{ 
            objResponse = RE_ArchetypeCtrl.insertReferralForResident(objResource,locationID, bConsentAgreed);
        }catch(Exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_BasicSearchCtrl.class.getName(),'insertReferralForResident', e.getMessage()+' '+e.getStackTraceString(), true);}
        return objResponse;
    }
    /********************************************************************************************
* @author       Pankaj
* @date         07/17/2019
* @methodname   getKeywordSearchResults()
* @description  This methods is used to get the search results based on keyword
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getKeywordSearchResults(String strKeyword, String strZipCode, String iPageSize, String pageNumber, String screen, String setResourceIds,String setLocResourceIds){
        
        String sKeyword = String.escapeSingleQuotes(strKeyword);
        String sZipCode = String.escapeSingleQuotes(strZipCode);
        //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
        String sPageSize = String.isNotBlank(iPageSize)?String.escapeSingleQuotes(iPageSize):iPageSize;
        String sContactId;
        String sUserLocation;
        Double dblLat;
        Double dblLon;
        Boolean bSuccess = false;
        Boolean bIsGuestUser = false;
        Boolean bIsResidentUser = false;
        Boolean bIsCPUser = false;
        Boolean bIsAgencyUser = false;//RE_Release 1.1 - Agency user capture- Mohan
        Location objLocationData;
        Set<Id> setResouceIdsPagination=new Set<Id>();
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Set<Id> setGlobalLocaResourceIds = new Set<Id>();
        String switchCaseKey;
        try{                                                                        
            if(UserInfo.getUserType() != 'Guest'){
                sContactId = GeneralUtility.getLoggedInUserContactId();
               //SSP Merge Fixes - Kojashree Kakariya
               // String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
                String sRole = GeneralUtility.getLoggedInUserSelectedRole();
               // Updated By Kojashree Kakariya
                Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sRole);
                switchCaseKey = (objContact.ContactGeoLocation__c != null && objContact.mailingpostalcode==sZipCode) ? 'TRUE' : 'FALSE';
                switch on (switchCaseKey) {
                    when 'TRUE' {
                        objLocationData = objContact.ContactGeoLocation__c;
                        dblLat = Double.valueOf(objLocationData.latitude);
                        dblLon = Double.valueOf(objLocationData.longitude);
                        sUserLocation = objLocationData.latitude+'##'+objLocationData.longitude;
                    }
                    when 'FALSE'{
                        String strLatLong = GeneralUtility.getLatLong(String.escapeSingleQuotes(sZipCode));
                        if(strLatLong!=null){
                            List<String> lstLatLong = strLatLong.split('##');
                            dblLat = Double.valueOf(lstLatLong[0]);
                            dblLon = Double.valueOf(lstLatLong[1]);
                            sUserLocation = dblLat +'##'+dblLon;
                            objLocationData = Location.newInstance(dblLat, dblLon);
                        } 
                    }
                } // Updated By Kojashree -- FR Fixes
                
            }else{
                
                String strLatLong = GeneralUtility.getLatLong(String.escapeSingleQuotes(sZipCode));
                switchCaseKey = (strLatLong!=null) ? 'TRUE' : 'FALSE';
                switch on (switchCaseKey) {
                    when 'TRUE'{
                        List<String> lstLatLong = strLatLong.split('##');
                        dblLat = Double.valueOf(lstLatLong[0]);
                        dblLon = Double.valueOf(lstLatLong[1]);
                        sUserLocation = dblLat +'##'+dblLon;
                        objLocationData = Location.newInstance(dblLat, dblLon); 
                    }
                    when 'FALSE'{
                        
                    }
                }
                
            } 
            RE_CreateLightningServerResponse objResponeUserRole = RE_RDResidentViewCtrl.getLoggedInUserRole();
            String sUserZip;
            if(objResponeUserRole != null){
                bIsGuestUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsGuestUser'));
                bIsResidentUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsResidentorGuest'));
                bIsCPUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsCPUserProfile'));
                bIsAgencyUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsAgencyUserProfile'));//RE_Release 1.1 - Agency user capture- Mohan
            }
            List<RE_ResourceDetailWrapper> lstResourceWrapper = new List<RE_ResourceDetailWrapper>();
            List<RE_ResourceWrapperSearch> lstResourceWrapperLatest = new List<RE_ResourceWrapperSearch>();
            if(Resource__c.getSObjectType().getDescribe().isAccessible() && Account.getSObjectType().getDescribe().isAccessible() &&
               Location__c.getSObjectType().getDescribe().isAccessible() && RE_Taxonomy__c.getSObjectType().getDescribe().isAccessible()
               && LocationResource__c.getSObjectType().getDescribe().isAccessible()){
                   // basic keyword search
                   
                   Set<Id> setGlobalSearchResourceIds = new Set<Id>();
                   switchCaseKey = (pageNumber!=null && Integer.valueOf(pageNumber)>0) ? 'TRUE' : 'FALSE';
                   switch on (switchCaseKey) {
                       when 'TRUE'{
                           setGlobalSearchResourceIds=(Set<Id>)JSON.deserialize(setResourceIds,Set<Id>.class);
                           setGlobalLocaResourceIds=(Set<Id>)JSON.deserialize(setLocResourceIds,Set<Id>.class);  
                       }
                       when 'FALSE'{
                           List<List<sObject>> searchList = RE_SharingByPassCtrl.getSearchResults(sKeyword);
                           List<Resource__c> objResource = (List<Resource__c>)searchList[0];
                           List<Account> objAccountList = (List<Account>)searchList[1];
                           List<Location__c> objLocationList = (List<Location__c>)searchList[2];
                           List<RE_Taxonomy__c> objTaxonomyList = (List<RE_Taxonomy__c>)searchList[3];
                           List<LocationResource__c> objLocationResourceList = (List<LocationResource__c>)searchList[4];
                           for(Resource__c obj : objResource){
                               if(obj.Name != null && obj.Name.containsIgnoreCase(sKeyword) && obj.Organization__r.IsClaimed__c == false || (obj.Organization__r.IsClaimed__c == true && obj.Organization__r.Status__c == RE_GlobalConstants.sAccountStatus)){
                                   setGlobalSearchResourceIds.add(obj.Id); // adding resource ids to set
                               }
                           }
                           //Getting resource from Account
                           Set<Id> setAccountIds = new Set<Id>();
                           for(Account obj : objAccountList){
                               if(obj.Name.containsIgnoreCase(sKeyword) ||(obj.CommonlyUsedName__c != null && obj.CommonlyUsedName__c.containsIgnoreCase(sKeyword)) || (obj.Description != null && obj.Description.containsIgnoreCase(sKeyword)) || (obj.Email__c != null && obj.Email__c.containsIgnoreCase(sKeyword)) || (obj.Phone != null && obj.Phone.containsIgnoreCase(sKeyword)) || (obj.Website != null && obj.Website.containsIgnoreCase(sKeyword))){
                                   setAccountIds.add(obj.Id); // adding resource ids to set
                               }
                           }
                           Set<Id> resourceidsFromAccountIds= new Set<Id>();
                           resourceidsFromAccountIds=RE_SharingByPassCtrl.getResourceIdsFromAccounts(setAccountIds);
                           if(resourceidsFromAccountIds!= null && !resourceidsFromAccountIds.isEmpty()){
                               setGlobalSearchResourceIds.addAll(resourceidsFromAccountIds);
                           }
                           //Getting resource from Location
                           Set<Id> setResLocationIds = new Set<Id>();
                           for(Location__c obj : objLocationList){
                               if(obj.Name.containsIgnoreCase(sKeyword) || (obj.Address1__c != null && obj.Address1__c.containsIgnoreCase(sKeyword)) ||
                                  (obj.City__c != null && obj.City__c.containsIgnoreCase(sKeyword)) || (obj.State__c != null && obj.State__c.containsIgnoreCase(sKeyword)) ||
                                  (obj.Email__c != null && obj.Email__c.containsIgnoreCase(sKeyword)) || (obj.Phone__c != null && obj.Phone__c.containsIgnoreCase(sKeyword))){
                                      setResLocationIds.add(obj.Id); // adding resource ids to set
                                  }
                           }
                           Set<Id> resourceIDsfromLocationIDs=new Set<Id>();
                           resourceIDsfromLocationIDs=RE_BasicSearchHelper.getResourceIdsFromResourceLocation(setResLocationIds) ;
                           if(resourceIDsfromLocationIDs!= null && !resourceIDsfromLocationIDs.isEmpty()){
                               setGlobalSearchResourceIds.addAll(resourceIDsfromLocationIDs);
                           }
                           //Getting resource from Taxonomy
                           Set<Id> setTaxonomyIds = new Set<Id>();
                           for(RE_Taxonomy__c obj : objTaxonomyList){
                               if((obj.Name != null && obj.Name.containsIgnoreCase(sKeyword)) || (obj.Description__c != null && obj.Description__c.containsIgnoreCase(sKeyword))){
                                   setTaxonomyIds.add(obj.Id); // adding resource ids to set
                               }
                           }
                           Set<Id> resourceIDsfromTaxonomy=new Set<Id>();
                           resourceIDsfromTaxonomy=RE_BasicSearchHelper.getResourceTaxonomiesIds(setTaxonomyIds);
                           if( resourceIDsfromTaxonomy!= null && !resourceIDsfromTaxonomy.isEmpty()){
                               setGlobalSearchResourceIds.addAll(resourceIDsfromTaxonomy);  
                           }
                           
                           for(LocationResource__c obj:objLocationResourceList){
                               if((obj.ResourceDescription__c != null && obj.ResourceDescription__c.containsIgnoreCase(sKeyword))
                                  || (obj.Phone__c != null && obj.Phone__c.containsIgnoreCase(sKeyword))){
                                      setGlobalLocaResourceIds.add(obj.id);
                                  }
                           }
                       }
                   }

                   Map<String,Resource__c> mapResources = new Map<String,Resource__c>();
                   List<Resource__c>  lstResources = new List<Resource__c>();
                   //Commented by Payal for aggregate query(342978)
                   /*Integer sGlbResLen = 0;
sGlbResLen = (setGlobalSearchResourceIds!=null)?setGlobalSearchResourceIds.size():sGlbResLen;*/
                   Double sGlbResLen=0;
                   
                   
                   String loggedinUser = RE_GlobalConstants.sEmptyString;
                   List<RE_ResourceDetailWrapper.Location> lstResourceLocation = new List<RE_ResourceDetailWrapper.Location>();
                   RE_GlobalConstants.SWITCH_CONSTANTS switchCaseglobalresourceIds = (setGlobalSearchResourceIds != null || setGlobalLocaResourceIds!=null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                   switch on (switchCaseglobalresourceIds) {
                       when SWITCH_SUCCESS { 
                           Map<String, String> mapInputs=new Map<String,String>();
                           mapInputs.put('dblLat',String.valueOf(dblLat));
                           mapInputs.put('dblLon',String.valueOf(dblLon));
                           //RE_Release 1.2 – SIT Error Log- Payal Dubela– Fixing error log
                           mapInputs.put('iPageSize',(!String.isEmpty(sPageSize))?sPageSize:Label.Keyword_Search_PageLimit);
                           mapInputs.put('pageNumber',pageNumber!=null?pageNumber:'0');
                           List<LocationResource__c> lstLocationResources = new List<LocationResource__c>();
                           Set<Id> setLocationIds = new Set<Id>();
                           Set<Id> resourceIds = new Set<Id>();
                           RE_GlobalConstants.SWITCH_CONSTANTS switchCaseLatLong = (dblLat != null && dblLon != null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                           switch on (switchCaseLatLong) {
                               when SWITCH_SUCCESS { 
                                   lstLocationResources = RE_BasicSearchHelper.getLocationResources(setGlobalSearchResourceIds, setGlobalLocaResourceIds,mapInputs);
                                   //Added to get Aggregate records in one go(Bug:342978)
                                   sGlbResLen=RE_BasicSearchHelper.getLocationResourcesCount(setGlobalSearchResourceIds, setGlobalLocaResourceIds,mapInputs);
                                   for(LocationResource__c obj : lstLocationResources){
                                       setLocationIds.add(obj.Location__c);
                                       resourceIds.add(obj.Resource__c);
                                   }
                               }
                           }
                           if(screen=='searchkeyword'){
                               // commented by Pankaj 10/28/2019
                               lstResources=RE_SharingByPassCtrl.fetchResourceDataSearch((Set<String>)JSON.deserialize(JSON.serialize(resourceIds), Set<String>.class)); 
                           }
                           for(Resource__c obResource : lstResources){
                               mapResources.put(obResource.id, obResource);  
                           }
                           
                           RE_GlobalConstants.SWITCH_CONSTANTS switchCaseGuest = (UserInfo.getUserType() != 'Guest')? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                           switch on (switchCaseGuest) {
                               when SWITCH_SUCCESS { 
                                   loggedinUser = GeneralUtility.getLoggedInUserContactId();
                               }
                           }
                           Map<String, Favorite__c> mapFavorites = new Map<String, Favorite__c>();
                           if(bIsCPUser == true || bIsAgencyUser == true ){
                               mapFavorites = RE_SharingByPassCtrl.getMyFavorite(resourceIds,setLocationIds);
                           }
                           Map<Id, Referral__c> mapResourceVsReferal = new Map<Id, Referral__c>();
                           if(bIsResidentUser == true){ 
                               mapResourceVsReferal = RE_BasicSearchHelper.getResidentReferrals(resourceIds);
                           } 
                           Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocationResources);
                           // added by Pankaj as part of pagination. defect#341424
                           Map<String,Map<String,String>> mapSDOHCategory = GeneralUtility.fetchFieldsPicklistValueAPIName('Resource__c','SdohDomain__c');
                           Map<String,String> mapSDOHCategoryAPINameLabel = new Map<String,String>();
                           
                           for(String sField : mapSDOHCategory.get('SdohDomain__c').keySet()){
                               mapSDOHCategoryAPINameLabel.put(mapSDOHCategory.get('SdohDomain__c').get(sField), sField);
                           }
                           RE_GlobalConstants.SWITCH_CONSTANTS switchCaseScreen = (screen=='searchkeyword')? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE; 
                           switch on (switchCaseScreen){
                               when SWITCH_SUCCESS{
                                   Map<String, List<RE_ResourceWrapperSearch.Location>> mapResourceLocation = new Map<String, List<RE_ResourceWrapperSearch.Location>>();
                                   for(LocationResource__c obj : lstLocationResources){
                                       if(obj.Resource__r.Organization__r.isClaimed__c == false || (obj.Resource__r.Organization__r.isClaimed__c == true && obj.Resource__r.Organization__r.Status__c == RE_GlobalConstants.sAccountStatus)){
                                           RE_ResourceWrapperSearch objWrapper = new RE_ResourceWrapperSearch();
                                           Id resourceId = obj.Resource__c;
                                           RE_ResourceWrapperSearch.Location objLoc = new RE_ResourceWrapperSearch.Location();
                                           objLoc.id = obj.Location__c;
                                           objLoc.locResourceId = obj.Id;
                                           objLoc.Name = obj.Location__r.Name;
                                           objLoc.locationAddress1 = obj.Location__r.Address1__c;
                                           objLoc.locationAddress2 = obj.Location__r.Address2__c;
                                           objLoc.locationCity = obj.Location__r.City__c;
                                           objLoc.locationState = obj.Location__r.State__c;  
                                           objLoc.locationCounty = obj.Location__r.County__c;  
                                           objLoc.locationZip = String.valueOf(obj.Location__r.Zip__c);  
                                           objLoc.locationZipExt = String.valueOf(obj.Location__r.ZipExtensionCode__c);
                                           if(!String.isBlank(obj.Phone__c)){
                                               objLoc.pointOfContactPhone = GeneralUtility.formatphonenumber(obj.Phone__c);
                                           }else if(!String.isBlank(obj.TollFree__c)){
                                               objLoc.pointOfContactPhone = GeneralUtility.formatphonenumber(obj.TollFree__c);
                                           }
                                           objLoc.pointOfContactEmail = String.isBlank(obj.Location__r.Email__c)?obj.Location__r.Account__r.Email__c:obj.Location__r.Email__c;
                                           objLoc.specialInstructions = obj.Location__r.SpecialLocationInstructions__c;  
                                           if(obj.Location__r.Geolocation__Latitude__s != null && obj.Location__r.Geolocation__Longitude__s != null){
                                               objLoc.locationLatLong = obj.Location__r.Geolocation__Latitude__s +'##'+ obj.Location__r.Geolocation__Longitude__s;
                                           }
                                           objLoc.locationOperatingHours = JSON.serialize(mapLocationIdOperatingHours.get(obj.Id));
                                           //Get Open today and open weekend logic
                                           List<String> daysClosed = new List<String>();
                                           String currentDay = DateTime.now().format('EEEE'); 
                                           if(obj.Location__r.DaysLocationClosed__c !=null){                                               
                                               for(String locClosed : obj.Location__r.DaysLocationClosed__c.split(';')){
                                                   daysClosed.add(locClosed);
                                               }
                                           }
                                           objLoc.lstClosedDays = daysClosed;
                                           objLoc.Notes = obj.Notes__c != null ? obj.Notes__c:'';
                                           RE_ResourceWrapperSearch.Account objAccount = new RE_ResourceWrapperSearch.Account();
                                           objAccount.accId = obj.Resource__r.Organization__c;
                                           objAccount.accName = obj.Resource__r.Organization__r.Name;
                                           objAccount.accAddress1 = obj.Resource__r.Organization__r.ShippingStreet;
                                           objAccount.accCity = obj.Resource__r.Organization__r.ShippingCity;
                                           objAccount.accState = obj.Resource__r.Organization__r.ShippingState;
                                           objAccount.accZip = obj.Resource__r.Organization__r.ShippingPostalCode;
                                           objWrapper.resourceId = obj.Resource__c;
                                           objWrapper.referralId = (mapResourceVsReferal.get(obj.Location__c) != null && mapResourceVsReferal.get(obj.Location__c).Location__c==obj.Location__c &&  mapResourceVsReferal.get(obj.Location__c).Resource__c == obj.Resource__c) ?String.valueof(mapResourceVsReferal.get(obj.Location__c).Id) :'';
                                           objWrapper.account = objAccount;
                                           objWrapper.accountId = obj.Resource__r.Organization__c;
                                           objWrapper.accountName = obj.Resource__r.Organization__r.Name;
                                           objWrapper.accountStatus = obj.Resource__r.Organization__r.Status__c;
                                           objWrapper.accountIsClaimed = obj.Resource__r.Organization__r.IsClaimed__c;
                                           objWrapper.resourceId = obj.Resource__c;
                                           objWrapper.resourceName = obj.Resource__r.Name;
                                           objWrapper.resourceDescription = obj.ResourceDescription__c;
                                           objWrapper.url =(obj.Location__r!=null && obj.Location__r.LocationWebsite__c!=null)?obj.Location__r.LocationWebsite__c:obj.Resource__r.Organization__r.Website;
                                           objWrapper.specialInstructions = obj.Location__r.SpecialLocationInstructions__c;  
                                           objWrapper.resourceMiles = RE_MyPlanHelper.getDistance(objLocationData, obj.Location__r.Geolocation__c, 'mi');
                                           objWrapper.resoucrePOCPhone = (!String.isEmpty(obj.Phone__c))?GeneralUtility.formatphonenumber(obj.Phone__c):((!String.isEmpty(obj.TollFree__c))?GeneralUtility.formatphonenumber(obj.TollFree__c):'');
                                               objWrapper.resourcePOCEmail   = obj.Location__r.Email__c;
                                           objWrapper.bIsFav = false;
                                           if(loggedinUser != RE_GlobalConstants.sEmptyString && mapFavorites.containsKey(obj.Id) && mapFavorites.get(obj.Id).Contact__c == loggedinUser){
                                               objWrapper.bIsFav = true;
                                           }
                                           RE_ResourceWrapperSearch.Domain objDomain = new RE_ResourceWrapperSearch.Domain();
                                           objDomain.domainName = mapSDOHCategoryAPINameLabel.get(obj.Resource__r.SdohDomain__c);
                                           objDomain.domainValue = obj.Resource__r.SdohDomain__c;
                                           objDomain.domainImage = '';
                                           List<RE_ResourceWrapperSearch.Domain> lstResourceDomains = new List<RE_ResourceWrapperSearch.Domain>();
                                           lstResourceDomains.add(objDomain);
                                           objWrapper.lstDomains =  lstResourceDomains; 
                                           objWrapper.userLatLong = sUserLocation;
                                           objWrapper.lstResourceLocations = new List<RE_ResourceWrapperSearch.Location>{objLoc};
                                               //Added to get Referrals as a part of Wrapper
                                               objWrapper.objResource = mapResources.get(obj.Resource__c);
                                           lstResourceWrapperLatest.add(objWrapper);
                                       }
                                   }
                               }  
                           }// Updated By Kojashree FR Issue
                           //Added by Payal (Performance issue)

                       }
                   }
                   if(screen=='searchkeyword' && lstResourceWrapperLatest!=null){
                       mapResponse.put('searchresults', lstResourceWrapperLatest);
                   }
                   mapResponse.put('bIsGuestUser',bIsGuestUser);
                   mapResponse.put('bIsResidentUser', bIsResidentUser);
                   mapResponse.put('bIsCPUser',bIsCPUser);
                   mapResponse.put('bIsAgencyUser',bIsAgencyUser);//RE_Release 1.1 - Agency user capture- Mohan
                   mapResponse.put('sUserZip',sUserZip);
                   mapResponse.put('sGlbResLen',sGlbResLen);
                   mapResponse.put('setGlobalSearchResourceIds',setGlobalSearchResourceIds);
                   mapResponse.put('setGlobalLocResourceIds',setGlobalLocaResourceIds);
                   RE_GlobalConstants.SWITCH_CONSTANTS switchCaseLoggedInUser= (GeneralUtility.getLoggedInUserProfileName() != RE_GlobalConstants.strGuestProfileName)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                   switch on (switchCaseLoggedInUser) {
                       when SWITCH_SUCCESS { 
                           Id contactId = GeneralUtility.getLoggedInUserContactId();
                           Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(contactId, RE_GlobalConstants.CITIZEN_INDIVIDUAL);
                           if(objContact.MailingPostalCode != null && objContact.MailingStreet != null&& objContact.MailingCity != null && objContact.MailingState != null && objContact.MailingCountry != null){
                               mapResponse.put('mylocationdata',JSON.serialize(objContact));
                           }
                       }
                   }
                   bSuccess = true;
               }else{
                   LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_BasicSearchCtrl', 'getKeywordSearchResults', 'Insufficient Read Access on objects', true);
               }
        }catch(Exception e){errorMap.put('error', e.getMessage()); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_BaiscSearchCtrl', 'getKeywordSearchResults', e.getMessage()+' '+e.getStackTraceString(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
* @author       Nupoor
* @date         07/17/2019
* @methodname   getSubCategorySearchResults()
* @description  This methods is used to get the search results based on selected category and subcategory
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getSubCategorySearchResults(String strZipCode, String strDomain, String strCategory, String strSubcategory, 
                                                                               String iPageSize, String pageNumber, String screen,String setResourceIds){
                                                                                   //SOQL changes made for the following 
                                                                                   String sZipCode = String.escapeSingleQuotes(strZipCode);
                                                                                   String sDomain = String.escapeSingleQuotes(strDomain);
                                                                                   String sCategory = String.escapeSingleQuotes(strCategory);
                                                                                   String sSubcategory = String.escapeSingleQuotes(strSubcategory);
                                                                                   //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
                                                                                   String sPageSize=String.isNotBlank(iPageSize)?String.escapeSingleQuotes(iPageSize):iPageSize;
                                                                                   String spageNumber=String.isNotBlank(pageNumber)?String.escapeSingleQuotes(pageNumber):pageNumber;
                                                                                   String strScreen=String.isNotBlank(screen)?String.escapeSingleQuotes(screen):screen;
                                                                                   String resourceIdSet=String.isNotBlank(setResourceIds)?String.escapeSingleQuotes(setResourceIds):setResourceIds;
                                                                                   RE_CreateLightningServerResponse objResponse;
                                                                                   try{
                                                                                       Map<String, String> mapInputs = new Map<String, String>();
                                                                                       mapInputs.put('sZipCode',sZipCode);
                                                                                       mapInputs.put('sDomain',sDomain);
                                                                                       mapInputs.put('sCategory',sCategory);
                                                                                       mapInputs.put('sSubcategory',sSubcategory);
                                                                                       mapInputs.put('iPageSize',sPageSize!=null?sPageSize:'50000');
                                                                                       mapInputs.put('pageNumber',spageNumber!=null?spageNumber:'0');
                                                                                       mapInputs.put('screen',strScreen);
                                                                                       mapInputs.put('setResourceIds',resourceIdSet);
                                                                                       objResponse = getSubCategorySearchRecords(mapInputs);
                                                                                   }catch(Exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_BasicSearchCtrl.class.getName(),'getSubCategorySearchResults', e.getMessage()+' '+e.getStackTraceString(), true);}
                                                                                   return objResponse;
                                                                               }
    /********************************************************************************************
* @author       Nupoor
* @date         07/17/2019
* @methodname   getSubCategorySearchResults()
* @description  This methods is used to get the search results based on selected category and subcategory
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    public static RE_CreateLightningServerResponse getSubCategorySearchRecords(Map<String, String> mapInputs){
        String sZipCode= mapInputs.get('sZipCode');
        String sDomain=mapInputs.get('sDomain');
        String sCategory=mapInputs.get('sCategory'); 
        String sSubcategory=mapInputs.get('sSubcategory'); 
        String iPageSize = mapInputs.get('iPageSize');
        String pageNumber = mapInputs.get('pageNumber');
        String screen = mapInputs.get('screen');
        String setResourceIds = mapInputs.get('setResourceIds');
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        List<RE_ResourceDetailWrapper> lstSearchResults = new List<RE_ResourceDetailWrapper>();
        List<RE_Config__c> lstSearchConfigResults = new List<RE_Config__c>();
        List<RE_Resource_Taxonomy__c> lstResourceTaxonomies = new List<RE_Resource_Taxonomy__c>();
        List<LocationResource__c> lstLocationResources = new List<LocationResource__c>();
        Map<String, List<RE_ResourceDetailWrapper.Location>> mapResourceLocations = new Map<String, List<RE_ResourceDetailWrapper.Location>>();        
        Set<String> setTaxonomyIds = new Set<String>();
        //Set<Id> setResourceIds = new Set<Id>();
        Set<Id> setLocationIds = new Set<Id>();
        //Map<Id,  Map<String, String>> mapLocationIdOperatingHours = new Map<Id,  Map<String, String>>();
        Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = new Map<Id,  Map<String, List<String>>>();
        Map<Id, Double> mapResourceWithMiles = new Map<Id, Double>();
        String sContactId;
        Double dblLat;
        Double dblLon;
        Location objLocationData;
        String sUserLocation;
        String switchCaseKey;
        try{
                //SSP Merge Fixes - Kojashree Kakariya
                String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
                String sRole = GeneralUtility.getLoggedInUserSelectedRole();
                   if(UserInfo.getUserType() != 'Guest' && !String.isEmpty(sZipCode)){
                sContactId = GeneralUtility.getLoggedInUserContactId();

               //  Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sProfileName);
               // Updated By Kojashree Kakariya
                Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sRole);
                // FR Issue Fixes
                switchCaseKey = (objContact.ContactGeoLocation__c != null && objContact.mailingpostalcode==sZipCode) ? 'TRUE' : 'FALSE';
                switch on (switchCaseKey) {
                    when 'TRUE'{
                        objLocationData = objContact.ContactGeoLocation__c;
                        dblLat = Double.valueOf(objLocationData.latitude);
                        dblLon = Double.valueOf(objLocationData.longitude);
                        sUserLocation = objLocationData.latitude+'##'+objLocationData.longitude;  
                    }
                    when 'FALSE'{
                        String strLatLong = GeneralUtility.getLatLong(String.escapeSingleQuotes(sZipCode));
                        
                        if(strLatLong!=null){
                            List<String> lstLatLong = strLatLong.split('##');
                            dblLat = Double.valueOf(lstLatLong[0]);
                            dblLon = Double.valueOf(lstLatLong[1]);
                            sUserLocation = dblLat +'##'+dblLon;
                            objLocationData = Location.newInstance(dblLat, dblLon);
                        } 
                    }
                }
              
               
            }else{
                String strLatLong = GeneralUtility.getLatLong(sZipCode);
                if(strLatLong!=null){
                    List<String> lstLatLong = strLatLong.split('##');
                    dblLat = Double.valueOf(lstLatLong[0]);
                    dblLon = Double.valueOf(lstLatLong[1]);
                    sUserLocation = dblLat +'##'+dblLon;
                    objLocationData = Location.newInstance(dblLat, dblLon);
                }
            }
            
            String searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
            mapInputs.put('searchConfigRecId',searchConfigRecId);
            
            mapResponse.put('domain', GeneralUtility.fetchPicklistLabel('RE_Config__c', 'Domain__c', sDomain));
            mapResponse.put('category', GeneralUtility.fetchPicklistLabel('RE_Config__c', 'Category__c', sCategory));
            mapResponse.put('subcategory', GeneralUtility.fetchPicklistLabel('RE_Config__c', 'Subcategory__c', sSubcategory));     

            Boolean bIsGuestUser = false;
            Boolean bIsResidentUser = false;
            Boolean bIsCPUser = false;
            Boolean bIsAgencyUser = false;//RE_Release 1.1 - Agency user capture- Mohan
            // updated by Kojashree -- SSP Merge Fixes
            if(sProfileName == RE_GlobalConstants.strGuestProfileName){
                bIsGuestUser = true;
            }else{
                if(sRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                    bIsResidentUser = true; 
                }
                if(sRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || sRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF || sRole == RE_GlobalConstants.ASSISTER){
                    bIsCPUser = true;
                }
                if(sRole == RE_GlobalConstants.CASE_WORKER || sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR){
                    bIsAgencyUser = true;
                } 
            }
           /* if(sProfileName == RE_GlobalConstants.strCitizenProfileName){
                bIsResidentUser = true;
            }else if(sProfileName == RE_GlobalConstants.strCommunityProfileName || sProfileName == RE_GlobalConstants.RE_ASSISTER_PROFILE){
                bIsCPUser = true;
            }else if(sProfileName == RE_GlobalConstants.strGuestProfileName){
                bIsGuestUser = true;
            }else if(sProfileName == RE_GlobalConstants.strAgencyProfileName){// RE_Release 1.1 - Agency user capture- Mohan
                bIsAgencyUser = true;
            }*/
            lstSearchConfigResults = RE_SharingByPassCtrl.getSearchConfigResults(mapInputs);
            for(RE_Config__c config : lstSearchConfigResults){
                setTaxonomyIds.add(config.Taxonomy__c);
            }

            Set<Id> setGlobalSearchResourceIds = new Set<Id>();
            if(pageNumber!=null && Integer.valueOf(pageNumber)>0){
                setGlobalSearchResourceIds=(Set<Id>)JSON.deserialize(setResourceIds,Set<Id>.class);
            }else{
                lstResourceTaxonomies = getResourceTaxonomies(setTaxonomyIds);
                for(RE_Resource_Taxonomy__c resource : lstResourceTaxonomies){
                    setGlobalSearchResourceIds.add(resource.Resource__c);
                }
            }
            Map<String, String> mapdataInputs=new Map<String,String>();
            mapdataInputs.put('dblLat',String.valueOf(dblLat));
            mapdataInputs.put('dblLon',String.valueOf(dblLon));  
            mapdataInputs.put('pageNumber',pageNumber);
            mapdataInputs.put('iPageSize',iPageSize);
            mapdataInputs.put('sDomain',sDomain);
            
            if(dblLat != null && dblLon != null){
                lstLocationResources = RE_BasicSearchHelper.getLocationResources(setGlobalSearchResourceIds,new Set<Id>(), mapdataInputs);
                for(LocationResource__c loc : lstLocationResources){
                    setLocationIds.add(loc.Location__c);
                }
            }
            Integer sGlbResLen = 0;
            sGlbResLen = (setGlobalSearchResourceIds!=null)?setGlobalSearchResourceIds.size():sGlbResLen;
            
            Map<String, Favorite__c> mapFavorites = new Map<String, Favorite__c>();
            // added by Pankaj [12/20/2019] as part of perf issue
            if(bIsCPUser == true || bIsAgencyUser == true ){
                mapFavorites = RE_SharingByPassCtrl.getMyFavorite(setGlobalSearchResourceIds,setLocationIds);
            }
            mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocationResources);
            Map<Id, Referral__c> mapResourceVsReferal = new Map<Id, Referral__c>();
            if(bIsResidentUser == true){
                mapResourceVsReferal = RE_BasicSearchHelper.getResidentReferrals(setGlobalSearchResourceIds);
            }
            if(screen=='searchbycategory'){
                //Get the locations for each resource          
                for(LocationResource__c loc : lstLocationResources){ 
                    if(mapResourceLocations.containsKey(loc.Resource__c)){
                        List<RE_ResourceDetailWrapper.Location> lstLocations = mapResourceLocations.get(loc.Resource__c);
                        Map<String, Object> mapWrapperInputs = new Map<String, Object>();
                        mapWrapperInputs.put('locationresource',loc);
                        mapWrapperInputs.put('operatinghours',mapLocationIdOperatingHours);
                        mapWrapperInputs.put('location',objLocationData);
                        mapWrapperInputs.put('miles',mapResourceWithMiles);
                        List<RE_ResourceDetailWrapper.Location> lstLocationsData = getLocationWrapper (mapWrapperInputs);
                        lstLocations.addAll(lstLocationsData);
                        mapResourceLocations.put(loc.Resource__c, lstLocations);
                    }else{
                        Map<String, Object> mapWrapperInputs = new Map<String, Object>();
                        mapWrapperInputs.put('locationresource',loc);
                        mapWrapperInputs.put('operatinghours',mapLocationIdOperatingHours);
                        mapWrapperInputs.put('location',objLocationData);
                        mapWrapperInputs.put('miles',mapResourceWithMiles);
                        List<RE_ResourceDetailWrapper.Location> lstLocations = getLocationWrapper (mapWrapperInputs);
                        mapResourceLocations.put(loc.Resource__c, lstLocations);
                    }
                }
            }
            
            // added by Pankaj as part of displaying null resources
            Map<String,String> mapSDOHCategoryAPINameLabel = new Map<String,String>();
            Map<String,Map<String,String>> mapSDOHCategory = GeneralUtility.fetchFieldsPicklistValueAPIName('Resource__c','SdohDomain__c');
            for(String sField : mapSDOHCategory.get('SdohDomain__c').keySet()){
                mapSDOHCategoryAPINameLabel.put(mapSDOHCategory.get('SdohDomain__c').get(sField), sField);
            }
            
            //creating the response wrapper
            Map<String, RE_ResourceDetailWrapper> responseMap = new Map<String, RE_ResourceDetailWrapper>();
            for(LocationResource__c obj : lstLocationResources){
                RE_ResourceDetailWrapper objWrapper = new RE_ResourceDetailWrapper();
                List<RE_ResourceDetailWrapper.Location> lstResourceLocations = new List<RE_ResourceDetailWrapper.Location>();
                lstResourceLocations = mapResourceLocations.get(obj.Resource__c);
                RE_ResourceDetailWrapper.Account objAccount = new RE_ResourceDetailWrapper.Account();
                objAccount.accId = obj.Resource__r.Organization__c;
                objAccount.accName = obj.Resource__r.Organization__r.Name;
                objAccount.accAddress1 = obj.Resource__r.Organization__r.ShippingStreet;
                objAccount.accCity = obj.Resource__r.Organization__r.ShippingCity;
                objAccount.accState = obj.Resource__r.Organization__r.ShippingState;
                objAccount.accZip = obj.Resource__r.Organization__r.ShippingPostalCode;
                objWrapper.account = objAccount;
                if(bIsResidentUser == true){
                    objWrapper.bHasReferral = (mapResourceVsReferal.get(obj.Location__c) != null && mapResourceVsReferal.get(obj.Location__c).Location__c==obj.Location__c &&  mapResourceVsReferal.get(obj.Location__c).Resource__c == obj.Resource__c)? true :false;
                    objWrapper.referralId = (mapResourceVsReferal.get(obj.Location__c) != null && mapResourceVsReferal.get(obj.Location__c).Location__c==obj.Location__c &&  mapResourceVsReferal.get(obj.Location__c).Resource__c == obj.Resource__c) ?String.valueof(mapResourceVsReferal.get(obj.Location__c).Id):'';
                }else{
                    objWrapper.bHasReferral = false;
            objWrapper.referralId = '';
                }
                objWrapper.accountId = obj.Resource__r.Organization__c;
                objWrapper.accountName = obj.Resource__r.Organization__r.Name;
                objWrapper.accountStatus = obj.Resource__r.Organization__r.Status__c;
                objWrapper.accountIsClaimed = obj.Resource__r.Organization__r.IsClaimed__c;
                objWrapper.resourceId = obj.Resource__c;
                objWrapper.resourceName = obj.Resource__r.Name;
                objWrapper.resourceDescription = obj.ResourceDescription__c;
                //Nandita 11-Feb-2020: updated the ctrl to reference location resource fields
                //objWrapper.whatToBring = obj.Resource__r.WhatToBring__c;
                //objWrapper.Fees = obj.Resource__r.Fees__c;
                objWrapper.Fees = obj.Fees__c;
                objWrapper.whatToBring = obj.WhatToBring__c;
                objWrapper.url = (obj.Location__r!=null && obj.Location__r.LocationWebsite__c!=null)?obj.Location__r.LocationWebsite__c:obj.Resource__r.Organization__r.Website;
                objWrapper.specialInstructions = obj.Location__r.SpecialLocationInstructions__c;                  
                if(mapResourceWithMiles != null && mapResourceWithMiles.get(obj.Resource__c) != null){
                    Decimal dMile = Decimal.valueOf(mapResourceWithMiles.get(obj.Resource__c));
                    objWrapper.resourceMiles = dMile.setScale(1, RoundingMode.CEILING);                    
                }
                objWrapper.bIsFav = false;
                objWrapper.resoucrePOCPhone = (!String.isEmpty(obj.Phone__c))?GeneralUtility.formatphonenumber(obj.Phone__c):((!String.isEmpty(obj.TollFree__c))?GeneralUtility.formatphonenumber(obj.TollFree__c):'');
                    objWrapper.resourcePOCEmail   = obj.Location__r.Account__r.Email__c;
                if(sContactId != RE_GlobalConstants.sEmptyString && mapFavorites.containsKey(obj.Id) && mapFavorites.get(obj.Id).Contact__c == sContactId){
                    objWrapper.bIsFav = true;
                }
                RE_ResourceDetailWrapper.Domain objDomain = new RE_ResourceDetailWrapper.Domain();
                
                objDomain.domainName = mapSDOHCategoryAPINameLabel.get(obj.Resource__r.SdohDomain__c);
                //objDomain.domainName = String.valueOf(obj.getSobject('Resource__r').get('resourceDomain'));
                objDomain.domainValue = obj.Resource__r.SdohDomain__c;
                objDomain.domainImage = RE_GlobalConstants.sEmptyString;
                List<RE_ResourceDetailWrapper.Domain> lstResourceDomains = new List<RE_ResourceDetailWrapper.Domain>();
                lstResourceDomains.add(objDomain);
                objWrapper.lstDomains =  lstResourceDomains;
                objWrapper.lstResourceLocations = lstResourceLocations;   
                objWrapper.userLatLong = sUserLocation;                
                if(!responseMap.containsKey(obj.Resource__c)){                    
                    responseMap.put(obj.Resource__c, objWrapper);
                    lstSearchResults.add(objWrapper);
                }
            }
            if(GeneralUtility.getLoggedInUserProfileName() != RE_GlobalConstants.strGuestProfileName){
                Id contactId = GeneralUtility.getLoggedInUserContactId();
                Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(contactId, RE_GlobalConstants.CITIZEN_INDIVIDUAL);
                if(objContact.MailingPostalCode != null && objContact.MailingStreet != null && objContact.MailingCity != null && objContact.MailingState != null  && objContact.MailingCountry != null){
                    mapResponse.put('mylocationdata',JSON.serialize(objContact));
                }
            }
            mapResponse.put('lstSearchResults', lstSearchResults);
            mapResponse.put('bIsGuestUser',bIsGuestUser);
            mapResponse.put('bIsResidentUser', bIsResidentUser);
            mapResponse.put('bIsCPUser',bIsCPUser);
            mapResponse.put('bIsAgencyUser',bIsAgencyUser);    //RE_Release 1.1 - Agency user capture- Mohan
            mapResponse.put('sUserLocation',sUserLocation);
            mapResponse.put('sGlbResLen',sGlbResLen);
            mapResponse.put('setGlobalSearchResourceIds',setGlobalSearchResourceIds);
            bSuccess = true;
        }catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_BasicSearchCtrl', 'getSubCategorySearchRecords', e.getMessage()+' '+e.getStackTraceString(), true);}
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
* @author       Nupoor
* @date         07/17/2019
* @methodname   getLocationWrapper()
* @description  This methods is used to get the search results based on selected category and subcategory
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    public static List<RE_ResourceDetailWrapper.Location> getLocationWrapper(Map<String, Object> mapInputs){
        
        LocationResource__c loc = (LocationResource__c)mapInputs.get('locationresource');
        Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours= (Map<Id,  Map<String, List<String>>>)mapInputs.get('operatinghours');
        
        Location objLocationData = (Location)mapInputs.get('location'); 
        Map<Id, Double> mapResourceWithMiles = (Map<Id, Double>)mapInputs.get('miles'); 
        List<RE_ResourceDetailWrapper.Location> lstLocations = new List<RE_ResourceDetailWrapper.Location>();
        RE_ResourceDetailWrapper.Location objLoc = new RE_ResourceDetailWrapper.Location();
        objLoc.id = loc.Location__c;
        objLoc.locResourceId = loc.Id;
        objLoc.Name = loc.Location__r.Name;
        if(!String.isBlank(loc.Phone__c)){
            objLoc.pointOfContactPhone = GeneralUtility.formatphonenumber(loc.Phone__c); 
        }else if(!String.isBlank(loc.TollFree__c)){
            objLoc.pointOfContactPhone = GeneralUtility.formatphonenumber(loc.TollFree__c);
        }
        objLoc.pointOfContactEmail = String.isBlank(loc.Location__r.Email__c)?loc.Location__r.Account__r.Email__c:loc.Location__r.Email__c;
        objLoc.locationAddress1 = loc.Location__r.Address1__c;
        objLoc.locationAddress2 = loc.Location__r.Address2__c;
        objLoc.locationCity = loc.Location__r.City__c;
        objLoc.locationState = loc.Location__r.State__c;  
        objLoc.locationCounty = loc.Location__r.County__c;  
        objLoc.locationZip = String.valueOf(loc.Location__r.Zip__c); 
        objLoc.locationZipExt = String.valueOf(loc.Location__r.ZipExtensionCode__c); 
        objLoc.specialInstructions = loc.Location__r.SpecialLocationInstructions__c; 
        if(loc.Location__r.Geolocation__Latitude__s != null && loc.Location__r.Geolocation__Longitude__s != null){
            objLoc.locationLatLong = loc.Location__r.Geolocation__Latitude__s +'##'+ loc.Location__r.Geolocation__Longitude__s;  
        }
        objLoc.locationOperatingHours = JSON.serialize(mapLocationIdOperatingHours.get(loc.Id));
        Double dblMiles = RE_MyPlanHelper.getDistance(objLocationData, loc.Location__r.Geolocation__c, 'mi');
        mapResourceWithMiles.put(loc.Resource__c, dblMiles);
        List<String> daysClosed = new List<String>();
        String currentDay = DateTime.now().format('EEEE'); 
        if(loc.Location__r.DaysLocationClosed__c !=null){                                               
            for(String locClosed : loc.Location__r.DaysLocationClosed__c.split(';')){
                daysClosed.add(locClosed);
            }
        }
        objLoc.lstClosedDays = daysClosed;
        objLoc.Notes = loc.Notes__c != null ? loc.Notes__c:'';
        lstLocations.add(objLoc);
        return lstLocations;
    }
    /********************************************************************************************
* @author       Pankaj Mohanta
* @date         08/19/2019
* @methodname   getResourceTaxonomies()
* @description  This methods is used to get get the resource taxonomies
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    public static List<RE_Resource_Taxonomy__c> getResourceTaxonomies(Set<String> setTaxonomyIds){
        List<RE_Resource_Taxonomy__c> lstResourceTaxonomies = new List<RE_Resource_Taxonomy__c>();
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        String loggedinUser = RE_GlobalConstants.sEmptyString;
        Map<String,String> mapQueryParameters = new Map<String,String>();
        String sFieldsToQueryOnResTaxonomy = RE_DataBaseQueryFields.sFieldsOnResTaxonomy;
        String sWhereClauseForResTaxonomy = RE_DataBaseQueryFields.sWhereClauseForResTaxonomy;
        String sQuery;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForResTaxonomy);
        Map<Boolean,String> mapResponseResTaxonomy = RE_DataAccessChecker.getFieldsAccessibility('RE_Resource_Taxonomy__c',sFieldsToQueryOnResTaxonomy,mapQueryParameters);
        if(mapResponseResTaxonomy.get(true) != null){
            sQuery =  mapResponseResTaxonomy.get(true);
            lstResourceTaxonomies = RE_SharingBypassCtrl.getResourceTaxonomies(setTaxonomyIds, sQuery, sAccountStatus);

        }else{
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_BasicSearchCtrl','getResourceTaxonomies','***FLS Violation***'+mapResponseResTaxonomy.get(false),true);
        } 
        return lstResourceTaxonomies;
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
* @author       Pankaj Mohanta
* @date         08/19/2019
* @methodname   createFavorite()
* @description  This methods is used to create favoriterecord
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse createFavorite(String strLocationResId){
        return RE_SharingByPassCtrl.createFavorite(String.escapeSingleQuotes(strLocationResId));
    }
    
    /********************************************************************************************
* @author       Karthik Gulla
* @date         08/19/2019
* @methodname   connectDraftReferralsFromSearchResults()
* @description  This methods is used to connect Draft Referrals
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse connectDraftReferralsFromSearchResults(String sSchReferralId, Boolean bSchConsentAgreed){
        //RE_Release 1.4 – Iron Dome Changes(07/14) - Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        return RE_MyPlanCtrl.connectDraftReferrals(String.escapeSingleQuotes(sSchReferralId), bSchConsentAgreed);
    }
}