/**************************************************************************************************
* Class Name    : RE_ArchetypeDetailCtrl 
* Owner         : Ashwin Kasture
* Created Date  : 07/05/2019
* Description   : Archetype Detail Screen
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/05/2019  Ashwin Kasture   Initial Development
*  11/09/2019  Ashwin Kasture   1326 - Provide the ability to relate a given goal to multiple archetypes
**/
public with sharing class RE_ArchetypeDetailCtrl{
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         08/07/2019
    * @methodname   getArchetypeResources()
    * @description  This methods is linked with 'RE_Archetype' aura component which gives Resource Details in response
    * @param        String strZipCodeParam, String strArchetypeIdParam, String strSubArchetypeIdParam, String strDomainParam
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    
    public static RE_CreateLightningServerResponse getArchetypeResources(String strZipCodeParam, String strArchetypeIdParam, 
                                                                         String strSubArchetypeIdParam, String strDomainParam, 
                                                                         String strGoalParam, String strSeeAllLess,List<String> selectedHours)
    { 
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Boolean bSuccess = false;
        RE_ArchetypeDetailWrapper objAchetypeWrapper = new RE_ArchetypeDetailWrapper();
        try{
            if(strArchetypeIdParam != null && strSubArchetypeIdParam != null && strZipCodeParam!=null && strDomainParam!= null){
                objAchetypeWrapper = getResouceDetails(strZipCodeParam, strArchetypeIdParam, strSubArchetypeIdParam, strDomainParam, strGoalParam, strSeeAllLess,selectedHours);
                mapResponse.put('lstArchetypeDetails',objAchetypeWrapper);
                bSuccess = true;
            }     
        }
        catch(Exception e){
            bSuccess = false;
            errorMap.put('error',e.getMessage()+e.getLineNumber());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ArchetypeDetailCtrl','getArchetypeResources',e.getMessage()+' '+e.getStackTraceString(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         08/07/2019
    * @methodname   getResouceDetails()
    * @description  This methods is used to get Resource Details
    * @param        String strZipCodeParam, String strArchetypeIdParam, String strSubArchetypeIdParam, String strDomainParam
    * @return       RE_ArchetypeDetailWrapper  
    **********************************************************************************************/
    public static RE_ArchetypeDetailWrapper getResouceDetails(String strZipCodeParam, String strArchetypeIdParam, String strSubArchetypeIdParam, 
                                                               String strDomainParam, String strGoalParam, String strSeeAllLess,List<String> selectedHours){
        RE_ArchetypeDetailWrapper objAchetypeWrapper = new RE_ArchetypeDetailWrapper();
        List<RE_ArchetypeDetailWrapper.CategoryBlockCls> lstCategoryBlock = new List<RE_ArchetypeDetailWrapper.CategoryBlockCls>();
        List<RE_ArchetypeDetailWrapper.GoalBlockCls> lstGoalBlock = new List<RE_ArchetypeDetailWrapper.GoalBlockCls>();
        List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> lstResourceTile = new List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls>();
        String sContactId;
        Double dblLat;
        Double dblLon;
        Location objLocationData;
        String sUserLocation;
        String strLatLong;
        Integer resourceCount = 0;
        Set<Id> setGoalId = new Set<Id>();
        Set<Id> setResourceId = new Set<Id>();
        Set<Id> setTaxonomyId = new Set<Id>();
        Set<Id> setLocationId = new Set<Id>();
        Set<Id> setLocResId = new Set<Id>();
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        List<LocationResource__c> lstLocationResource = new List<LocationResource__c>();
        List<RE_Config__c> lstGoalArchetypeConfig = new List<RE_Config__c>();
        List<RE_Config__c> lstConfig = new List<RE_Config__c>();
        List<RE_Config__c> lstDomainConfigs = new List<RE_Config__c>();
        List<RE_Resource_Taxonomy__c> lstResourceTaxonomy = new List<RE_Resource_Taxonomy__c>();
        List<Resource__c> lstResource = new List<Resource__c>();
        List<Referral__c> lstReferals = new List<Referral__c>();
        List<Favorite__c> lstFavoritesRes = new List<Favorite__c>();
        
        Map<Id, List<RE_Config__c>> mapTaxonomyWithConfig = new Map<Id, List<RE_Config__c>>();
        Map<Id, LocationResource__c> mapResourceWithLocation = new Map<Id, LocationResource__c>();
        Map<Id, Double> mapResourceWithMiles = new Map<Id, Double>();
        Map<Id, String> mapResWithLocationLatLong = new Map<Id, String>();        
        Map<String, RE_Config__c> mapDomainLabelVsConfigs = new Map<String, RE_Config__c>();
        Map<String, List<RE_Config__c>> mapCatConfig = new Map<String, List<RE_Config__c>>();
        Map<Id, Referral__c> mapResourceVsReferal = new Map<Id, Referral__c>();
        Map<Id,map<String, List<String>>> mapOperatingHours = new Map<Id,map<String, List<String>>>();
        Map<Id,Favorite__c> mapResourceVsFavorites = new Map<Id,Favorite__c>();
        Boolean checkToday=false;
        Boolean checkWeekend=false;
        Boolean openToday=false;
        Boolean openWeekend=false;
        DateTime dt = System.now();
        String weekdayValue = dt.format('EEEE');
        
        objAchetypeWrapper.resourceCount = 0;
        objAchetypeWrapper.strZipcode = strZipCodeParam;
        //To check login User Roles
        RE_CreateLightningServerResponse objResponeUserRole = RE_RDResidentViewCtrl.getLoggedInUserRole();
        if(objResponeUserRole != null){
            objAchetypeWrapper.bIsGuestUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsGuestUser'));
            objAchetypeWrapper.bIsResidentUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsResidentorGuest'));
            objAchetypeWrapper.bIsCPUserProfile = Boolean.valueOf(objResponeUserRole.objectData.get('bIsCPUserProfile'));
            objAchetypeWrapper.bIsAgencyUserProfile = Boolean.valueOf(objResponeUserRole.objectData.get('bIsAgencyUserProfile'));
        }
        
        if(UserInfo.getUserType() != 'Guest'){
            sContactId = GeneralUtility.getLoggedInUserContactId();
            String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
            // Added By Kojashree -- SSP Merge Fixes
            String sRole = GeneralUtility.getLoggedInUserSelectedRole();
            Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sRole);
          
           // Contact objContact = RE_SharingByPassCtrl.getCitizenContactDetails(sContactId, sProfileName);
            if (objContact.ContactGeoLocation__c != null && objContact.mailingpostalcode==strZipCodeParam){
                objLocationData = objContact.ContactGeoLocation__c;
                dblLat = Double.valueOf(objLocationData.latitude);
                dblLon = Double.valueOf(objLocationData.longitude);
                strLatLong = objLocationData.latitude+'##'+objLocationData.longitude;
            }
            else{
                strLatLong = GeneralUtility.getLatLong(strZipCodeParam);
                if(strLatLong!=null){
                List<String> lstLatLong = strLatLong.split('##');
                dblLat = Double.valueOf(lstLatLong[0]);
                dblLon = Double.valueOf(lstLatLong[1]);
                objLocationData = Location.newInstance(dblLat, dblLon);
                }
            }
        }else{
            strLatLong = GeneralUtility.getLatLong(strZipCodeParam);
            if(strLatLong!=null){
                List<String> lstLatLong = strLatLong.split('##');
                dblLat = Double.valueOf(lstLatLong[0]);
                dblLon = Double.valueOf(lstLatLong[1]);
                objLocationData = Location.newInstance(dblLat, dblLon);
            }
        }
        objAchetypeWrapper.strUserLatLong = strLatLong;
        List<String> lstDomainsSplit = new List<String>();
        if(String.isNotBlank(strDomainParam)){
            lstDomainsSplit = strDomainParam.split(',');
        }
        List<String> lstGoalParam = new List<String>();
        if(String.isNotBlank(strGoalParam)){
            lstGoalParam = strGoalParam.split(',');
        }
        Boolean bExecuteOnce = true;
        lstGoalArchetypeConfig = RE_ArchetypeDetailCtrl.getGoalArchetypeConfigRecords(strArchetypeIdParam, strSubArchetypeIdParam, lstGoalParam);
        for(RE_Config__c objGoalArch: lstGoalArchetypeConfig){
            setGoalId.add(objGoalArch.Goal__c);
            if(bExecuteOnce){
                objAchetypeWrapper.strArchetypeId = objGoalArch.Archetype__r.ParentArchetype__c;
                objAchetypeWrapper.strArchetypeTitle = objGoalArch.Archetype__r.ParentArchetype__r.Title__c;
                bExecuteOnce = false;
            }
        }
        
        Set<String> setUniqueGoalsTaxonomy = new Set<String>();
        lstConfig = RE_ArchetypeDetailCtrl.getGoalConfigRecords(setGoalId, lstDomainsSplit);
        for(RE_Config__c objConfig: lstConfig){
            setTaxonomyId.add(objConfig.Taxonomy__c);            
            if(mapCatConfig.containsKey(objConfig.Goal__r.Domain__c) && !setUniqueGoalsTaxonomy.contains(objConfig.Goal__c+','+objConfig.Taxonomy__c)){
                List<RE_Config__c> lstConfigRecords = mapCatConfig.get(objConfig.Goal__r.Domain__c);
                lstConfigRecords.add(objConfig);
                mapCatConfig.put(objConfig.Goal__r.Domain__c,lstConfigRecords);
            }else if(!setUniqueGoalsTaxonomy.contains(objConfig.Goal__c+','+objConfig.Taxonomy__c)){
                mapCatConfig.put(objConfig.Goal__r.Domain__c, new List<RE_Config__c>{objConfig});
            }
            setUniqueGoalsTaxonomy.add(objConfig.Goal__c+','+objConfig.Taxonomy__c);
        }
        
        Set<String> setKeySetDomain = mapCatConfig.keySet();        
        lstDomainConfigs = RE_ArchetypeDetailCtrl.getDomainConfigRecords(lstDomainConfigs, setKeySetDomain);
        for(RE_Config__c objDomainCon:lstDomainConfigs){
            mapDomainLabelVsConfigs.put(objDomainCon.Domain__c, objDomainCon);
        }
        lstResourceTaxonomy = RE_ArchetypeDetailCtrl.getResourceTaxonomy(lstResourceTaxonomy, setTaxonomyId, sAccountStatus);        
        for(RE_Resource_Taxonomy__c objResTax: lstResourceTaxonomy){
            setResourceId.add(objResTax.Resource__c);
        }
        
        Set<String> setUniquesResLoc = new Set<String>();
        lstLocationResource = RE_ArchetypeDetailCtrl.getLocationResource(lstLocationResource, dblLat, dblLon, setResourceId);
        for(LocationResource__c objResources:lstLocationResource){
            setLocResId.add(objResources.Id);
            setLocationId.add(objResources.Location__c);            
            Double dblMiles = RE_MyPlanHelper.getDistance(objLocationData, objResources.Location__r.Geolocation__c, 'mi');
            if(mapResourceWithMiles.containsKey(objResources.Resource__c) && mapResourceWithMiles.get(objResources.Resource__c) > dblMiles && !setUniquesResLoc.contains(objResources.Resource__c+','+objResources.Location__c)){
                mapResourceWithMiles.put(objResources.Resource__c, dblMiles);
                mapResourceWithLocation.put(objResources.Resource__c, objResources);
                Location objLocationLatLong = objResources.Location__r.Geolocation__c;
                String strLocationLatLang = (objLocationLatLong != null) ? objLocationLatLong.getLatitude() + '##' + objLocationLatLong.getLongitude() : '';
                mapResWithLocationLatLong.put(objResources.Resource__c, strLocationLatLang);
            }
            else if(!mapResourceWithMiles.containsKey(objResources.Resource__c) && !setUniquesResLoc.contains(objResources.Resource__c+','+objResources.Location__c)){
                mapResourceWithMiles.put(objResources.Resource__c, dblMiles);
                mapResourceWithLocation.put(objResources.Resource__c, objResources);
                Location objLocationLatLong = objResources.Location__r.Geolocation__c;
                String strLocationLatLang = (objLocationLatLong != null) ? objLocationLatLong.getLatitude() + '##' + objLocationLatLong.getLongitude() : '';
                mapResWithLocationLatLong.put(objResources.Resource__c, strLocationLatLang);
            }
            setUniquesResLoc.add(objResources.Resource__c+','+objResources.Location__c);
        }        
        
        //Start - new Changes        
        Set<String> setUniqueResTaxo = new Set<String>();
        Map<Id, List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls>> mapTaxoVsMilesWrapper = new Map<Id, List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls>>(); //Added for new Changes        
        for(RE_Resource_Taxonomy__c objResTax: lstResourceTaxonomy){
            if(mapTaxoVsMilesWrapper.containsKey(objResTax.Taxonomy__c) && mapResourceWithLocation != null && mapResourceWithMiles !=null && mapResourceWithMiles.containsKey(objResTax.Resource__c) && !setUniqueResTaxo.contains(objResTax.Taxonomy__c+','+objResTax.Resource__c)){
                List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls> lstConfigRecords = mapTaxoVsMilesWrapper.get(objResTax.Taxonomy__c);
                RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxoWrapper = new RE_ArchetypeDetailWrapper.ResTaxoMilesCls();
                objResTaxoWrapper.objResourceTaxonomy = objResTax;
                objResTaxoWrapper.objLocationResource = mapResourceWithLocation.get(objResTax.Resource__c);
                objResTaxoWrapper.resourceMiles = mapResourceWithMiles.get(objResTax.Resource__c);
                lstConfigRecords.add(objResTaxoWrapper);
                mapTaxoVsMilesWrapper.put(objResTax.Taxonomy__c,lstConfigRecords);
            }
            else if(mapResourceWithLocation != null && mapResourceWithMiles != null && mapResourceWithMiles.containsKey(objResTax.Resource__c) && !setUniqueResTaxo.contains(objResTax.Taxonomy__c+','+objResTax.Resource__c)){
                RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxoWrapper = new RE_ArchetypeDetailWrapper.ResTaxoMilesCls();
                objResTaxoWrapper.objResourceTaxonomy = objResTax;
                objResTaxoWrapper.objLocationResource = mapResourceWithLocation.get(objResTax.Resource__c);
                objResTaxoWrapper.resourceMiles = mapResourceWithMiles.get(objResTax.Resource__c);
                mapTaxoVsMilesWrapper.put(objResTax.Taxonomy__c, new List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls>{objResTaxoWrapper});
            }
            setUniqueResTaxo.add(objResTax.Taxonomy__c+','+objResTax.Resource__c);
        }
        //End - new Changes
        
        if(!setLocationId.isEmpty()){
            mapOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationId,lstLocationResource);
        }
        if(!objAchetypeWrapper.bIsGuestUser){
            lstReferals = RE_ArchetypeDetailCtrl.getReferralRecords(lstReferals, setResourceId);
            for(Referral__c objReferal: lstReferals){
                mapResourceVsReferal.put(objReferal.Resource__c, objReferal);
            }
        }
        //To get the Favorites of Resources based on login user & Location Resources
        if(objAchetypeWrapper.bIsCPUserProfile || objAchetypeWrapper.bIsAgencyUserProfile){
            lstFavoritesRes = RE_ArchetypeDetailCtrl.getFavoriteResources(setLocResId);
            for(Favorite__c objFav: lstFavoritesRes){
                mapResourceVsFavorites.put(objFav.LocationResource__r.Resource__c, objFav);
            }               
        }
        
        Map<Id, List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls>> mapGoalVsMilesWrapper = new Map<Id, List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls>>();//Added for new changes
        Set<String> setUniqueGoalsMiles = new Set<String>();
        for(RE_Config__c objConfig: lstConfig){
            //Start - new Changes
            if(objConfig.Taxonomy__c != null && objConfig.Goal__c != null && mapGoalVsMilesWrapper.containsKey(objConfig.Goal__c) && mapTaxoVsMilesWrapper.containsKey(objConfig.Taxonomy__c) && !setUniqueGoalsMiles.contains(objConfig.Goal__c+','+objConfig.Taxonomy__c))
            {
                List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls> lstWrapperRecords = mapGoalVsMilesWrapper.get(objConfig.Goal__c);
                lstWrapperRecords.addAll(mapTaxoVsMilesWrapper.get(objConfig.Taxonomy__c));
                mapGoalVsMilesWrapper.put(objConfig.Goal__c, lstWrapperRecords);
            }else if(objConfig.Taxonomy__c != null && objConfig.Goal__c != null && mapTaxoVsMilesWrapper.containsKey(objConfig.Taxonomy__c) && !setUniqueGoalsMiles.contains(objConfig.Goal__c+','+objConfig.Taxonomy__c)){
                List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls> lstWrapperRecords = new List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls>();
                lstWrapperRecords.addAll(mapTaxoVsMilesWrapper.get(objConfig.Taxonomy__c));
                mapGoalVsMilesWrapper.put(objConfig.Goal__c, lstWrapperRecords);
            }
            setUniqueGoalsMiles.add(objConfig.Goal__c+','+objConfig.Taxonomy__c);
            //End - new Changes
        }

        //Hours Filter logic
        // Force Reviewer Fixes 
    RE_GlobalConstants.SWITCH_CONSTANTS switchSelectedHours = (selectedHours!=null && selectedHours.size()>0)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
switch on (switchSelectedHours) {
    when SWITCH_SUCCESS{
        for(String str :selectedHours){
            if(str == 'Open Today'){
                checkToday=true;
            }else if(str=='Open Weekends'){
                checkWeekend=true;
            }
        }
    }                                                              
    }
        /*--Assigning the Wrapper data--*/            
        List<RE_ArchetypeDetailWrapper.CategoryBlockCls> lstArCat = new List<RE_ArchetypeDetailWrapper.CategoryBlockCls>();
        List<RE_ArchetypeDetailWrapper.GoalBlockCls> lstArGoal;
        List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> lstArRes;
        Set<Id> setUniqueGoalId = new Set<Id>();
        for(String objCategory: mapCatConfig.keySet()){
            RE_ArchetypeDetailWrapper objAchetypeBlock;                
            RE_ArchetypeDetailWrapper.CategoryBlockCls objCatBlock;               
            RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock;
            RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock;
            
            objAchetypeBlock = new RE_ArchetypeDetailWrapper();
            //Category Block
            objCatBlock = new RE_ArchetypeDetailWrapper.CategoryBlockCls();                
            List<RE_Config__c> lstConfigRecord = mapCatConfig.get(objCategory);
            for(RE_Config__c objCon:lstConfigRecord)
            {
                if(!setUniqueGoalId.contains(objCon.Goal__c))
                {
                    setUniqueGoalId.add(objCon.Goal__c);
                    assignDomainBlock(objCatBlock, objCon, mapDomainLabelVsConfigs);
                    //Goal Block    
                    objGoalBlock = new RE_ArchetypeDetailWrapper.GoalBlockCls();
                    assignGoalBlock(objGoalBlock, objCon, strLatLong);                    
                    lstArGoal = new List<RE_ArchetypeDetailWrapper.GoalBlockCls>();
                    
                  // Force Reviewer Changes : Kojashree Kakariya 
                   RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (objCatBlock.lstGoalBlock != null && !objCatBlock.lstGoalBlock.isEmpty())? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                    switch on (switchCaseKey) {
                        when SWITCH_SUCCESS{
                           lstArGoal = objCatBlock.lstGoalBlock;  
                        }
                    }
                    lstArGoal.add(objGoalBlock);
                    objCatBlock.lstGoalBlock = lstArGoal;
                    //Start - New Changes
                    List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls> lstResTaxoMilesWrapper = mapGoalVsMilesWrapper.get(objCon.Goal__c);
                    if(lstResTaxoMilesWrapper !=null && !lstResTaxoMilesWrapper.isEmpty())
                    {
                        lstResTaxoMilesWrapper.sort();
                        Integer index = 0;
                        Integer iResourceCount = String.isNotBlank(strSeeAllLess) && strSeeAllLess.equals('see-all')? lstResTaxoMilesWrapper.size(): 2;
                        
                        //Filtered Records
                        List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls> lstFilteredResWrapper= new List<RE_ArchetypeDetailWrapper.ResTaxoMilesCls>();
                        for(RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles :lstResTaxoMilesWrapper){ 
                            openToday=false;
                            openWeekend=false;
                            Map<String, List<String>> mapLDayOperatingHours = new Map<String, List<String>>();
                            //Force Reviewer Fixes 
                            RE_GlobalConstants.SWITCH_CONSTANTS switchOperatingHours = (mapOperatingHours != null && mapOperatingHours.containsKey(objResTaxMiles.objLocationResource.Id))? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                            switch on (switchOperatingHours) {
                                when SWITCH_SUCCESS { 
                                    mapLDayOperatingHours = mapOperatingHours.get(objResTaxMiles.objLocationResource.Id);
                                    List<String> lstOperationHours = mapLDayOperatingHours.get(weekdayValue);
                                    List<String> lstOperationHoursSun = mapLDayOperatingHours.get('Sunday');
                                    List<String> lstOperationHoursSat = mapLDayOperatingHours.get('Saturday');
                                    if(checkToday==true && lstOperationHours!=null && String.isNotBlank(lstOperationHours[0]) && String.isNotBlank(lstOperationHours[1]) && lstOperationHours[2]=='false'){
                                         openToday=true;
                                    } // Modified by Kojashree -- FR Fixes
                                    if(checkWeekend==true && lstOperationHours!=null && (((String.isNotBlank(lstOperationHoursSat[0]) && String.isNotBlank(lstOperationHoursSat[1]) && lstOperationHoursSat[2]=='false') || (String.isNotBlank(lstOperationHoursSun[0]) && String.isNotBlank(lstOperationHoursSun[1])) && lstOperationHoursSun[2]=='false' ))){
                                         openWeekend=true;
                                    } 
                                }
                            }
                            if ((checkWeekend == true && openWeekend == true) &&
                                 (checkToday==true  && openToday == true)){
                                    lstFilteredResWrapper.add(objResTaxMiles);
                            }else if(checkWeekend == true && checkToday ==false 
                                    && openWeekend == true){
                                        lstFilteredResWrapper.add(objResTaxMiles);
                            }else if(checkToday==true && checkWeekend==false 
                                     && openToday == true){
                                        lstFilteredResWrapper.add(objResTaxMiles);
                            }else if(checkToday==false && checkWeekend==false){
                                lstFilteredResWrapper.add(objResTaxMiles);
                            }

                        }
                        objGoalBlock.resourceListSize=lstFilteredResWrapper.size();
                        for(RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles :lstFilteredResWrapper){    
                                 
                            if(index < iResourceCount)
                            {
                                objAchetypeWrapper.resourceCount += resourceCount+1;
                                objResblock = new RE_ArchetypeDetailWrapper.ResourceTileBlockCls();
                                assignResourceBlock(objResblock, objResTaxMiles);                            
                                assignLocationResBlock(objResblock, objResTaxMiles, mapResWithLocationLatLong, mapOperatingHours);
                                assignFavoritesData(objResblock, objResTaxMiles, mapResourceVsFavorites);
                                assignReferalsData(objResblock, objResTaxMiles, mapResourceVsReferal);
                                lstArRes = new List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls>();
                                if(objGoalBlock.lstResourceTile != null && !objGoalBlock.lstResourceTile.isEmpty()){
                                    lstArRes = objGoalBlock.lstResourceTile;
                                }
                                lstArRes.add(objResblock);
                                objGoalBlock.lstResourceTile = lstArRes;
                                index = index+1;
                            }
                            else{
                                break;
                            }
                        }
                    }
                    //End - New Changes
                }
            }
            lstArCat.add(objCatBlock);
        }
        objAchetypeWrapper.lstCategoryBlock = lstArCat;
        return objAchetypeWrapper;
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         10/09/2019
    * @methodname   getGoalArchetypeConfigRecords()
    * @description  This methods is used to get the Config object records of Goal Archetype Mapping record type
    * @param        List<RE_Config__c> lstConfig
    * @return       List<RE_Config__c>  
    **********************************************************************************************/
    public static List<RE_Config__c> getGoalArchetypeConfigRecords(String strArchetypeIdParam, String strSubArchetypeIdParam, List<String> lstGoalParam){
        List<RE_Config__c> lstGoalArchetypeConfig = new List<RE_Config__c>();
        String goalArchetypeConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('GoalArchetypeMapping').getRecordTypeId();
        String sConfigQuery;
        String sFieldsToQueryOnConfigObj = RE_DataBaseQueryFields.sArcheFieldsToQueryOnGoalArcheConfigObj;
        String sWhereClauseOnConfigObj = '';
        String sFieldsToQueryOnConfig = sFieldsToQueryOnConfigObj;
        if(lstGoalParam !=null && !lstGoalParam.isEmpty()){
            sWhereClauseOnConfigObj = RE_DataBaseQueryFields.sArcheWhereClauseOnGoalArcheConfigObjWithGoal;
        }
        else{
            sWhereClauseOnConfigObj = RE_DataBaseQueryFields.sArcheWhereClauseOnGoalArcheConfigObjWOGoal;
        }        
        String sWhereClauseOnConfig = sWhereClauseOnConfigObj;
        Map<String,String> mapConfigQueryParameters = new Map<String,String>();
        mapConfigQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnConfig);
        Map<Boolean,String> mapConfigQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strConfigObjectName, sFieldsToQueryOnConfig, mapConfigQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapConfigQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sConfigQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strConfigObjectName, sFieldsToQueryOnConfig, mapConfigQueryParameters);
                
                lstGoalArchetypeConfig = Database.query(sConfigQuery);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeDetailCtrl.class.getName(), 'getGoalArchetypeConfigRecords', RE_GlobalConstants.FLS_ERROR + '' + mapConfigQueryResponse.get(false), true);
            }
        }
        return lstGoalArchetypeConfig;
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getGoalConfigRecords()
    * @description  This methods is used to get the Config object records of Goal record type
    * @param        List<RE_Config__c> lstConfig
    * @return       List<RE_Config__c>  
    **********************************************************************************************/
    public static List<RE_Config__c> getGoalConfigRecords(Set<Id> setGoalId, List<String> lstDomainsSplit){
        List<RE_Config__c> lstGoalConfig = new List<RE_Config__c>();
        String goalConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('Goal_Config').getRecordTypeId();
        String sConfigQuery;
        String sFieldsToQueryOnConfig = RE_DataBaseQueryFields.sFieldsToQueryOnConfigObj;
        String sWhereClauseOnConfigObj = RE_DataBaseQueryFields.sWhereClauseOnConfigObj;
        String sWhereClauseOnConfig = sWhereClauseOnConfigObj;
        Map<String,String> mapConfigQueryParameters = new Map<String,String>();
        mapConfigQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnConfig);
        Map<Boolean,String> mapConfigQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strConfigObjectName, sFieldsToQueryOnConfig, mapConfigQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapConfigQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sConfigQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strConfigObjectName, RE_DataBaseQueryFields.sFieldsToQueryOnConfigObjToLabel, mapConfigQueryParameters);
                
                lstGoalConfig = Database.query(sConfigQuery);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeDetailCtrl.class.getName(), 'getGoalConfigRecords', RE_GlobalConstants.FLS_ERROR + '' + mapConfigQueryResponse.get(false), true);
            }
        }
        return lstGoalConfig;
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getDomainConfigRecords()
    * @description  This methods is used to get the Config object records of Domain Record type
    * @param        List<RE_Config__c> lstDomainConfigs
    * @return       List<RE_Config__c>  
    **********************************************************************************************/
    public static List<RE_Config__c> getDomainConfigRecords(List<RE_Config__c> lstDomainConfigs, Set<String> setKeySetDomain){
        String domainConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('DomainConfig').getRecordTypeId();
        String sDomainConfigQuery;
        String sFieldsToQueryOnDomainConfig = RE_DataBaseQueryFields.sFieldsToQueryOnDomainConfigObj;
        String sWhereClauseOnDomainConfig = RE_DataBaseQueryFields.sWhereClauseOnDomainConfigObj;
        String sOrderByClauseDomainConfig = RE_DataBaseQueryFields.sOrderByClauseDomainConfigObj;
        Map<String,String> mapDomainConfigQueryParameters = new Map<String,String>();
        mapDomainConfigQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnDomainConfig);
        mapDomainConfigQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderByClauseDomainConfig);
        Map<Boolean,String> mapDomainConfigQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strConfigObjectName, sFieldsToQueryOnDomainConfig, mapDomainConfigQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapDomainConfigQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sDomainConfigQuery =  mapDomainConfigQueryResponse.get(true);
                lstDomainConfigs = Database.query(sDomainConfigQuery);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeDetailCtrl.class.getName(), 'getDomainConfigRecords', RE_GlobalConstants.FLS_ERROR + '' + mapDomainConfigQueryResponse.get(false), true);
            }
        }
        return lstDomainConfigs;
    }
    
    /****************************************************************************************************************
    * @author       Ashwin Kasture
    * @date         08/22/2019
    * @methodname   getFavoriteResources()
    * @description  This methods is used to get the Favorites of Resources based on login User & Location Resource.
    * @return       List<Favorite__c>
    *****************************************************************************************************************/
    public static List<Favorite__c> getFavoriteResources(Set<Id> setLocResId){
        // RE Security Changes - Guest User Security- Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        String sContactId = GeneralUtility.getLoggedInUserContactId();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        List<Favorite__c> lstFav = new List<Favorite__c>();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        String sFieldsApiName = RE_DataBaseQueryFields.sFieldsGetFavorites;
        String sWhereClause = RE_DataBaseQueryFields.sWhereClauseGetFavorites;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Favorite__c', sFieldsApiName, mapQueryParameters);
        Id sFavRecordTypeId = Schema.SObjectType.Favorite__c.getRecordTypeInfosByName().get('Resource Favorite').getRecordTypeId();
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sQuery =  mapResponseData.get(true);
                lstFav = RE_SharingByPassCtrl.getFavoriteResources(sQuery, setLocResId, sContactId,sFavRecordTypeId);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ArchetypeDetailCtrl','getFavoriteResources','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        return lstFav;
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getResourceTaxonomy()
    * @description  This methods is used to get the Resource Taxonomy records
    * @param        List<RE_Resource_Taxonomy__c> lstResourceTaxonomy
    * @return       List<RE_Resource_Taxonomy__c> 
    **********************************************************************************************/
    public static List<RE_Resource_Taxonomy__c> getResourceTaxonomy(List<RE_Resource_Taxonomy__c> lstResourceTaxonomy, Set<Id> setTaxonomyId, String sAccountStatus){
        String sResTaxonomyQuery;
        String sFieldsToQueryOnResTaxonomy = RE_DataBaseQueryFields.sFieldsToQueryOnResTaxonomy;
        String sWhereClauseOnResTaxonomy = RE_DataBaseQueryFields.sWhereClauseOnResTaxonomy;
        Map<String,String> mapResTaxonomyQueryParameters = new Map<String,String>();
        mapResTaxonomyQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnResTaxonomy);
        Map<Boolean,String> mapResTaxonomyQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strResTaxonomyObjectName, sFieldsToQueryOnResTaxonomy, mapResTaxonomyQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResTaxonomyQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sResTaxonomyQuery =  mapResTaxonomyQueryResponse.get(true);
                
                lstResourceTaxonomy = RE_SharingByPassCtrl.getResourceTaxonomy(sResTaxonomyQuery, setTaxonomyId, sAccountStatus);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeDetailCtrl.class.getName(), 'getResourceTaxonomy', RE_GlobalConstants.FLS_ERROR + '' + mapResTaxonomyQueryResponse.get(false), true);
            }
        }
        return lstResourceTaxonomy;
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getLocationResource()
    * @description  This methods is used to get the Location Resource records
    * @param        List<LocationResource__c> lstLocationResource
    * @return       List<LocationResource__c> 
    **********************************************************************************************/
    public static List<LocationResource__c> getLocationResource(List<LocationResource__c> lstLocationResource, Double dblLat, Double dblLon, Set<Id> setResourceId){
        String sLocResQuery;
        String sFieldsToQueryOnLocRes = RE_DataBaseQueryFields.sFieldsToQueryOnLocRes;
        String sWhereClauseOnLocRes = RE_DataBaseQueryFields.sArchetypeWhereClauseOnLocRes;
        String sOrderByClauseOnLocRes = RE_DataBaseQueryFields.sArchetypeOrderByClauseOnLocRes;
        Map<String,String> mapLocResQueryParameters = new Map<String,String>();
        mapLocResQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocRes);
        mapLocResQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderByClauseOnLocRes);
        Map<Boolean,String> mapLocResQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocResObjectName, sFieldsToQueryOnLocRes, mapLocResQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapLocResQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sLocResQuery =  mapLocResQueryResponse.get(true);
                Map<String, String> mapInputs = new Map<String, String>();
                mapInputs.put('sLocResQuery',sLocResQuery);
                mapInputs.put('dblLat',String.valueOf(dblLat));
                mapInputs.put('dblLon',String.valueOf(dblLon)); 
                if(dblLat!=null && dblLon!=null){
                    lstLocationResource = RE_SharingByPassCtrl.getLocationResource(mapInputs, setResourceId);
                }
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeDetailCtrl.class.getName(), 'getLocationResource', RE_GlobalConstants.FLS_ERROR + '' + mapLocResQueryResponse.get(false), true);
            }
        }
        return lstLocationResource;
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getReferralRecords()
    * @description  This methods is used to get the Referral records
    * @param        List<Referral__c> lstReferals
    * @return       List<Referral__c> 
    **********************************************************************************************/
    public static List<Referral__c> getReferralRecords(List<Referral__c> lstReferals, Set<Id> setResourceId){
        String sReferralQuery;
        String sFieldsToQueryOnReferral = RE_DataBaseQueryFields.sFieldsToQueryOnReferralObj;
        String sWhereClauseOnReferralWhenGuest = RE_DataBaseQueryFields.sWhereClauseOnReferralWhenGuest;
        String sWhereClauseOnReferralWhenNotGuest = RE_DataBaseQueryFields.sWhereClauseOnReferralWhenNotGuest;
        Map<String,String> mapReferralQueryParameters = new Map<String,String>();
        Map<Boolean,String> mapReferralQueryResponse = new Map<Boolean,String>();
        if(UserInfo.getUserType() == 'Guest'){      
            mapReferralQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReferralWhenGuest);
            mapReferralQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strReferralObjectName, sFieldsToQueryOnReferral, mapReferralQueryParameters);
            if(mapReferralQueryResponse.get(true) != null){
                sReferralQuery =  mapReferralQueryResponse.get(true);
                lstReferals = RE_SharingByPassCtrl.getReferralRecords(sReferralQuery,setResourceId,null);
            }
        }else{
            Id contactId = GeneralUtility.getLoggedInUserContactId();
            mapReferralQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReferralWhenNotGuest);
            mapReferralQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strReferralObjectName, sFieldsToQueryOnReferral, mapReferralQueryParameters);
            if(mapReferralQueryResponse.get(true) != null){
                sReferralQuery =  mapReferralQueryResponse.get(true);
                lstReferals = RE_SharingByPassCtrl.getReferralRecords(sReferralQuery,setResourceId,contactId);
            }
        }
        return lstReferals;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         04/10/2019
    * @methodname   assignDomainBlock()
    * @description  This methods is used to get the Domain from Goals Config.
    * @param        RE_ArchetypeDetailWrapper.CategoryBlockCls objCatBlock, RE_Config__c objCon, Map<String, RE_Config__c> mapDomainLabelVsConfigs
    * @return       void 
    **********************************************************************************************/
    public static void assignDomainBlock(RE_ArchetypeDetailWrapper.CategoryBlockCls objCatBlock, RE_Config__c objCon, Map<String, RE_Config__c> mapDomainLabelVsConfigs)
    {
        objCatBlock.strDomain = String.valueOf(objCon.getSobject('Goal__r').get('goalDomainLabel'));
        objCatBlock.strDomainCategory = String.valueOf(objCon.getSobject('Goal__r').get('goalCategoryLabel'));
        if(mapDomainLabelVsConfigs!=null && mapDomainLabelVsConfigs.get(objCon.Goal__r.Domain__c) != null){
            objCatBlock.strDomainImage = mapDomainLabelVsConfigs.get(objCon.Goal__r.Domain__c).DomainImage__c;
        }
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         4/10/2019
    * @methodname   assignGoalBlock()
    * @description  This methods is used to assign the Goal wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock, RE_Config__c objCon
    * @return       void 
    **********************************************************************************************/
    public static void assignGoalBlock(RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock, RE_Config__c objCon, String strLatLong)
    {
        objGoalBlock.goalId = objCon.Goal__c;
        objGoalBlock.goal = objCon.Goal__r.Title__c;
        objGoalBlock.goalDescription = objCon.Goal__r.Description__c; 
        objGoalBlock.goalDomain = objCon.Goal__r.Domain__c;
        objGoalBlock.strUserZipcodeLatLong = strLatLong;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         1/10/2019
    * @methodname   assignResourceBlock()
    * @description  This methods is used to assign the Resource wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles
    * @return       void 
    **********************************************************************************************/
    public static void assignResourceBlock(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles)
    {
        objResblock.resourceId = objResTaxMiles.objResourceTaxonomy.Resource__c;
        objResblock.resourceName = objResTaxMiles.objResourceTaxonomy.Resource__r.Name;
        objResblock.resourceSdohCategory = objResTaxMiles.objResourceTaxonomy.Resource__r.SdohDomain__c;
        objResblock.accountId = objResTaxMiles.objResourceTaxonomy.Resource__r.Organization__c;
        objResblock.accountProviderName = objResTaxMiles.objResourceTaxonomy.Resource__r.Organization__r.Name;
        objResblock.accountWebsite = objResTaxMiles.objResourceTaxonomy.Resource__r.Organization__r.Website;
        objResblock.accountStatus = objResTaxMiles.objResourceTaxonomy.Resource__r.Organization__r.Status__c;
        objResblock.accountIsClaimed = objResTaxMiles.objResourceTaxonomy.Resource__r.Organization__r.IsClaimed__c;
        objResblock.resourceMiles = objResTaxMiles.resourceMiles != null? objResTaxMiles.resourceMiles.setScale(2, RoundingMode.CEILING):null;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         01/10/2019
    * @methodname   assignLocationResBlock()
    * @description  This methods is used to assign the Location Resource wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, 
    *               RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles, Map<Id, Map<String, String>> mapOperatingHours
    * @return       void 
    **********************************************************************************************/
    public static void assignLocationResBlock(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles, Map<Id, String> mapResWithLocationLatLong, Map<Id, Map<String, List<String>>> mapOperatingHours)
    {
        if(objResTaxMiles.objLocationResource != null)
        { 
            objResblock.locationResourceId = objResTaxMiles.objLocationResource.Id;
            objResblock.locationId = objResTaxMiles.objLocationResource.Location__c;
            if(objResTaxMiles.objLocationResource.Phone__c != null && objResTaxMiles.objLocationResource.Phone__c!=''){
                objResblock.locationPhone = GeneralUtility.formatphonenumber(objResTaxMiles.objLocationResource.Phone__c);
            }else if(objResTaxMiles.objLocationResource.Tollfree__c!= null && objResTaxMiles.objLocationResource.Tollfree__c!=''){
                objResblock.locationPhone = GeneralUtility.formatphonenumber(objResTaxMiles.objLocationResource.Tollfree__c);
            }
            objResblock.resourceDescription = objResTaxMiles.objLocationResource.ResourceDescription__c;
            objResblock.locationEmail = String.isBlank(objResTaxMiles.objLocationResource.Location__r.Email__c)?objResTaxMiles.objLocationResource.Location__r.Account__r.Email__c:objResTaxMiles.objLocationResource.Location__r.Email__c;
            objResblock.locationAddress1 = objResTaxMiles.objLocationResource.Location__r.Address1__c;
            objResblock.locationAddress2 = objResTaxMiles.objLocationResource.Location__r.Address2__c;
            objResblock.locationCity = objResTaxMiles.objLocationResource.Location__r.City__c;
            objResblock.locationState = objResTaxMiles.objLocationResource.Location__r.State__c;
            objResblock.locationZipcode = String.valueOf(objResTaxMiles.objLocationResource.Location__r.Zip__c);
            objResblock.locationZipcodeExt = String.valueOf(objResTaxMiles.objLocationResource.Location__r.ZipExtensionCode__c);
            objResblock.locationWebsite = objResTaxMiles.objLocationResource.Location__r.LocationWebsite__c;
            Map<String, List<String>> mapLDayOperatingHours = new Map<String, List<String>>();
            if(mapOperatingHours != null && mapOperatingHours.containsKey(objResTaxMiles.objLocationResource.Id))
            mapLDayOperatingHours = mapOperatingHours.get(objResTaxMiles.objLocationResource.Id);
            objResblock.locationOperatingHours = JSON.serialize(mapLDayOperatingHours);
            if(objResTaxMiles.objLocationResource.Location__r.DaysLocationClosed__c != null){
                objResblock.locationIsClosedDay = objResTaxMiles.objLocationResource.Location__r.DaysLocationClosed__c;
            }else{
                objResblock.locationIsClosedDay ='';
            }
            objResblock.locationLatLong = mapResWithLocationLatLong.get(objResTaxMiles.objResourceTaxonomy.Resource__c);
            objResblock.resoucrePOCPhone = objResTaxMiles.objLocationResource.Location__r.PointofContactPhone__c;
            objResblock.resourcePOCEmail = objResTaxMiles.objLocationResource.Location__r.PointofContactEmail__c;
            objResblock.locResTimeNotes =objResTaxMiles.objLocationResource.Notes__c;
            
        }
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         1/10/2019
    * @methodname   assignFavoritesData()
    * @description  This methods is used to assign the Favorite wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles, Map<Id,Favorite__c> mapResourceVsFavorites
    * @return       void 
    **********************************************************************************************/
    public static void assignFavoritesData(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles, Map<Id,Favorite__c> mapResourceVsFavorites)
    {
        if(mapResourceVsFavorites != null && mapResourceVsFavorites.containsKey(objResTaxMiles.objResourceTaxonomy.Resource__c)){
            objResblock.favoriteId = mapResourceVsFavorites.get(objResTaxMiles.objResourceTaxonomy.Resource__c).Id;
        }else{
            objResblock.favoriteId = '';
        }
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         1/10/2019
    * @methodname   assignReferalsData()
    * @description  This methods is used to assign the Referal wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id, Referral__c> mapResourceVsReferal
    * @return       void 
    **********************************************************************************************/
    public static void assignReferalsData(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.ResTaxoMilesCls objResTaxMiles, Map<Id, Referral__c> mapResourceVsReferal)
    {
        if(mapResourceVsReferal != null && mapResourceVsReferal.get(objResTaxMiles.objResourceTaxonomy.Resource__c) != null){
            objResBlock.referralId = mapResourceVsReferal.get(objResTaxMiles.objResourceTaxonomy.Resource__c).Id;
            objResBlock.objReferral = mapResourceVsReferal.get(objResTaxMiles.objResourceTaxonomy.Resource__c);
            objResBlock.isConnectButtonDisabled = true;
        }else{
            objResBlock.referralId='';
            objResBlock.objReferral = null;
            objResBlock.isConnectButtonDisabled = false;
        }
    }
}