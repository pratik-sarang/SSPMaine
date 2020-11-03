/**
* Class Name    : RE_ResourceLocationCtrl
* Owner         : DELOITTE
* Created Date  : 01/28/2020
* Description   : Adding and updating the Location Resource details
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  01/28/2020  SRIKANTH       Initial Version
*  
**/
public with sharing class RE_ResourceLocationCtrl {
    
    /*********************************************************************************************************************************
* @author       Kojashree Kakariya
* @date         01/28/2020
* @methodname   updateLocationResource()
* @description  This updates the Resource Location details
* @param        
* @return       RE_CreateLightningServerResponse  
************************************************************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateResourceLocation(String locRes, String resID){
        String strResId=String.isNotBlank(resID)?String.escapeSingleQuotes(resID):'';
        RE_ResourceLocationCtrl.LocationResourceWrapper locationResource = (RE_ResourceLocationCtrl.LocationResourceWrapper)JSON.deserialize(locRes, RE_ResourceLocationCtrl.LocationResourceWrapper.class);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        try {
            //will update logic for updating Location Resource
            
            
            /* Location__c parentLocationObj = [Select MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,
ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,
SundayOpen__c,SundayClose__c from Location__c where id =: locationResource.slocationResOffering];*/
            
            String LocId =   String.escapeSingleQuotes(locationResource.slocationResOffering);
            Location__c parentLocationObj;
            String sFieldsApiNamesForDays = RE_DataBaseQueryFields.sDaysFieldsQueryLocation;       
            String sWhereClauseForDays = RE_DataBaseQueryFields.sWhereClauseForDays ;
            String sQuery;
            
            Map<String,String> mapQueryParameters = new Map<String,String>();
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForDays);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            
            Map<Boolean,String> mapLocation = RE_DataAccessChecker.getFieldsAccessibility('Location__c',sFieldsApiNamesForDays,mapQueryParameters);
            if(mapLocation.get(true) != null){
                sQuery =  mapLocation.get(true);
                parentLocationObj = Database.query(sQuery);
                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ResourceLocationCtrl','updateResourceLocation','***FLS Violation***'+mapLocation.get(false),true);
            }
            
            LocationResource__c resLocData = new LocationResource__c();
          //  resLocData.Id = locationResource.sLocationResourceId;
            if(locationResource.sLocationResourceId == '' || locationResource.sLocationResourceId == null){
               resLocData.Resource__c = strResId; 
               resLocData.Location__c = locationResource.slocationResOffering;
            }else{
                resLocData.Id = strResId;
            }
          
            resLocData.Status__c = locationResource.slocationResStatus;
            resLocData.Phone__c = locationResource.slocationResPhone;
            resLocData.Fax__c = locationResource.slocationResFax;
            resLocData.TollFree__c = locationResource.slocationResTollFree;
            resLocData.AgesServed__c = locationResource.slocationResAgesServed;
            resLocData.ResourceDescription__c = locationResource.slocationResDescription;
            resLocData.EligibilityDescription__c = locationResource.slocationResEligibilty;
            resLocData.Geography_Served__c = locationResource.slocationResGeoAgesServed;
            resLocData.FirstPointOfContactName__c = locationResource.slocationResFirstPOCName;
            resLocData.FirstPointofContactEmail__c = locationResource.slocationResFirstPOCEmail;
            resLocData.FirstPointofContactPhone__c = locationResource.slocationResFirstPOCPhone;
            resLocData.FirstPointOfContactTitle__c = locationResource.slocationResFirstPOCTitle;
            resLocData.SecondPointOfContactName__c = locationResource.slocationResSecondPOCName;
            resLocData.SecondPointOfContactTitle__c = locationResource.slocationResSecondPOCTitle;
            resLocData.SecondPointofContactPhone__c = locationResource.slocationResSecondPOCPhone;
            resLocData.SecondPointofContactEmail__c = locationResource.slocationResSecondPOCEmail;
            resLocData.TimeZone__c = locationResource.slocationResTimeZone;
            resLocData.Fees__c = locationResource.slocationResFees;
            resLocData.Notes__c = locationResource.slocationResNotes;
            resLocData.NextSteps__c = locationResource.slocationResNextSteps;
            resLocData.WhatToBring__c = locationResource.slocationResWhatToBring;
            resLocData.EligibilitySNAP__c = locationResource.blocationResSNAP;
            resLocData.EligibilityCCAP__c = locationResource.blocationResCCAP;
            resLocData.EligibilityTANF__c = locationResource.blocationResTANF;
            resLocData.EligibilityMedicaid__c = locationResource.blocationResMedicaid;
            resLocData.ResourceDescription__c = locationResource.slocationResDescription;
            resLocData.DaysClosed__c = locationResource.sDaysLocationClosed;
            
          //  resLocData.MondayOpen__c = locationResource.tlocationResMondayOpen != null?convertToLocalTime(locationResource.tlocationResMondayOpen):parentLocationObj.MondayOpen__c;
              
            if(locationResource.tlocationResMondayOpen != null ){
                resLocData.MondayOpen__c = convertToLocalTime(locationResource.tlocationResMondayOpen);
            }
            else{
                resLocData.MondayOpen__c = null;
            }
           
            if(locationResource.tlocationResMondayClose != null ){
                resLocData.MondayClose__c = convertToLocalTime(locationResource.tlocationResMondayClose);
            }
            else{
                resLocData.MondayClose__c = null;
            }
           
            if(locationResource.tlocationResTuesdayOpen != null ){
                resLocData.TuesdayOpen__c = convertToLocalTime(locationResource.tlocationResTuesdayOpen);
            }
            else{
                resLocData.TuesdayOpen__c = null;
            }
           
            if(locationResource.tlocationResTuesdayClose != null ){
                resLocData.TuesdayClose__c = convertToLocalTime(locationResource.tlocationResTuesdayClose);
            }
            else{
                resLocData.TuesdayClose__c = null;
            }
            
            if(locationResource.tlocationResWednesdayOpen != null ){
                resLocData.WednesdayOpen__c = convertToLocalTime(locationResource.tlocationResWednesdayOpen);
            }
            else{
                resLocData.WednesdayOpen__c = null;
            }
           
            if(locationResource.tlocationResWednesdayClose != null ){
                resLocData.WednesdayClose__c = convertToLocalTime(locationResource.tlocationResWednesdayClose);
            }
            else{
                  resLocData.WednesdayClose__c = null;
            }
            if(locationResource.tlocationResThursdayOpen != null ){
                resLocData.ThursdayOpen__c = convertToLocalTime(locationResource.tlocationResThursdayOpen);
            }
            else{
                resLocData.ThursdayOpen__c  = null;
            }
           
            if(locationResource.tlocationResThursdayClose != null ){
                resLocData.ThursdayClose__c = convertToLocalTime(locationResource.tlocationResThursdayClose);
            }else{
                //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue
                resLocData.ThursdayClose__c=null;
            }
          
             if(locationResource.tlocationResFridayOpen != null ){
                resLocData.FridayOpen__c = convertToLocalTime(locationResource.tlocationResFridayOpen);
            }
            else{
                resLocData.FridayOpen__c = null;
            }
           
          
            if(locationResource.tlocationResFridayClose != null ){
                resLocData.FridayClose__c = convertToLocalTime(locationResource.tlocationResFridayClose);
            }
            else{
                resLocData.FridayClose__c = null;
            }
            if(locationResource.tlocationResSaturdayOpen != null ){
                resLocData.SaturdayOpen__c = convertToLocalTime(locationResource.tlocationResSaturdayOpen);
            }
            else{
                resLocData.SaturdayOpen__c = null;
            }
           
            if(locationResource.tlocationResSaturdayClose != null ){
                resLocData.SaturdayClose__c = convertToLocalTime(locationResource.tlocationResSaturdayClose);
            }
            else{
                resLocData.SaturdayClose__c = null;
            }
            if(locationResource.tlocationResSundayOpen != null ){
                resLocData.SundayOpen__c = convertToLocalTime(locationResource.tlocationResSundayOpen);
            }
            else{
                resLocData.SundayOpen__c = null;
            }
           
          
            if(locationResource.tlocationResSundayClose != null ){
                resLocData.SundayClose__c = convertToLocalTime(locationResource.tlocationResSundayClose);
            }
            else{
                resLocData.SundayClose__c  = null;
            }

            
            if(locationResource.sLocationResourceId == null || locationResource.sLocationResourceId == ''){
                //insert the location resource record
                RE_DataAccessChecker.insertObject(LocationResource__c.getSObjectType(), resLocData);
                bSuccess = true;
            }else{
                //update the record
                RE_DataAccessChecker.updateObject(LocationResource__c.getSObjectType(),resLocData);
                bSuccess = true;
            }
            

        } catch (Exception e) {
            errorMap.put('error', e.getMessage());
            bSuccess = false;
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceLocation','updateResourceLocation', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    
    
    public static Time convertToLocalTime(String inputTime){
        
        /*Date dToday = system.today();
        
        Datetime dateToday =  Datetime.newInstanceGmt(dToday,inputTime);

        TimeZone tz = UserInfo.getTimeZone();
        
        String local = dateToday.format('HH:mm:ss');
        List<String> lstTimeParams = local.split(':');*/
        
        List<String> lstTimeParams = inputTime.split(':');
        Time timeData = Time.newInstance(integer.valueOf(lstTimeParams[0]),integer.valueOf(lstTimeParams[1]),0,0);

        return timeData;
        
    }
    
    /**************************************************************************************
* @author       Kojashree Kakariya
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
                    RE_ResourceLocationCtrl.LocationResourceWrapper objLocRes = new RE_ResourceLocationCtrl.LocationResourceWrapper(new LocationResource__c());
                    mapResponse.put('objLocRes', objLocRes);
                    
                } catch (Exception e) {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceLocation','getPickListValues',e.getMessage(), true);
                }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    @AuraEnabled
    public Static RE_CreateLightningServerResponse getResourceLocationDetails(String strRecordId) {
        String sRecordId = String.escapeSingleQuotes(strRecordId);
        GeneralUtility.isAuthenticatedUser();
        String sResult;
        Boolean bSuccess = false;
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        try{
            if(strRecordId != null){
                
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnLocationResourceCtrl;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnLocationResourceCtrl;
            String sQuery;
            
            Map<String,String> mapQueryParameters = new Map<String,String>();
            
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            
            Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsApiName,mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                           
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponse.get(true);
                    
                    List<LocationResource__c> lstLocationResource = Database.query(sQuery); 
                    if (lstLocationResource.isEmpty() == false) {//SIT Error Log Fix - Suresh
                        bSuccess = true;
                        mapResult.put('result',JSON.serialize(new LocationResourceWrapper(lstLocationResource[0])));
                        /*:::: Added by Suresh Starts ::::*/
                         Boolean bHasPermission = RE_OrganizationDetailsCtrl.userPermissionAccess();
                         mapResult.put('isAdminUser', bHasPermission);
                         /*:::: Added by Suresh Ends ::::*/
                        Boolean bAgencyHasPermission = RE_OrganizationDetailsCtrl.agencyUserPermissionAccess();
                        mapResult.put('isAgencyUser', bAgencyHasPermission);
                        //sResult = JSON.serialize(lstLocations[0]);
                    } 
                } 
                when SWITCH_FAILURE {
                    bSuccess = false; errorMap.put('error', 'Field access error.'); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','getLocationDetails','Some Fields doesn\'t have the required access :: '+mapResponse.get(false), true);
                    
                }
            }
            }
        }catch(Exception e){
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceLocation','getResourceLocationDetails',e.getMessage(),true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResult); 
    }

    @AuraEnabled
    public static RE_CreateLightningServerResponse checkResourceLocation(String strLocId,String strRecID) {
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        String locId=String.isNotBlank(strLocId)?String.escapeSingleQuotes(strLocId):'';
        String recId=String.isNotBlank(strRecID)?String.escapeSingleQuotes(strRecID):'';
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        try{
        String sWhereClause = RE_DataBaseQueryFields.sWhereClauseForLocationResource;
        String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnLocationResource;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sQuery;
        
        List<LocationResource__c> lstRecords=new List<LocationResource__c>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        
        Map<Boolean, String> mapResponsesObjectName = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c', sFieldsApiName, mapQueryParameters);
        
        if (mapResponsesObjectName.get(true) != null) {
            sQuery = mapResponsesObjectName.get(true);                    
        } else {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ClientsHelper','getData','Some Fields doesnt have the required access : '+mapResponsesObjectName.get(false),true);
        }
        Map<String, String> mapInputs= new Map<String,String>();
        if (sQuery != null) {
            lstRecords = RE_SharingByPassCtrl.checkLocationRes(sQuery,locId,recId);
        }
        if(lstRecords.size()>0){
            mapResult.put('isRecordFound',true);
        }else{
            mapResult.put('isRecordFound',false);
        }
         bSuccess=true;
        }catch(Exception e){
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ResourceLocation','checkLocationResource',e.getMessage(),true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResult); 

    }
    /*********************************************************************************************************************************
* @author       Kojashree Kakariya
* @date         01/28/2020
* @class        wrappper class for saving and updating Location Resource
* @description  Captures the details of Resource Location        
************************************************************************************************************************************/
    
    public class LocationResourceWrapper{
       
        @AuraEnabled  
        public String AccountId;
        @AuraEnabled
        public String sResourceId{get;set;}
        @AuraEnabled 
        public String sLocationResourceId{get;set;}
        @AuraEnabled 
        public String slocationResOffering{get;set;}
        @AuraEnabled 
        public String slocationResStatus{get;set;}
        @AuraEnabled 
        public String slocationResPhone{get;set;}
        @AuraEnabled 
        public String slocationResFax{get;set;}
        @AuraEnabled 
        public String slocationResTollFree{get;set;}
        @AuraEnabled 
        public String slocationResAgesServed{get;set;}
         @AuraEnabled 
        public String slocationResDescription{get;set;}
        @AuraEnabled 
        public String slocationResEligibilty{get;set;}
        @AuraEnabled 
        public String slocationResGeoAgesServed{get;set;}
        @AuraEnabled
        public String slocationResFirstPOCName{get;set;}
        @AuraEnabled
        public String slocationResFirstPOCTitle{get;set;}
        @AuraEnabled
        public String slocationResFirstPOCEmail{get;set;}
        @AuraEnabled
        public String slocationResFirstPOCPhone{get;set;}
        @AuraEnabled
        public String slocationResSecondPOCName{get;set;}
        @AuraEnabled
        public String slocationResSecondPOCTitle{get;set;}
        @AuraEnabled
        public String slocationResSecondPOCEmail{get;set;}
        @AuraEnabled
        public String slocationResSecondPOCPhone{get;set;}
        @AuraEnabled
        public String slocationResTimeZone{get;set;}
        @AuraEnabled
        public String slocationResFees{get;set;}
        @AuraEnabled
        public String slocationResNotes{get;set;}
        @AuraEnabled
        public String slocationResNextSteps{get;set;}
        @AuraEnabled
        public String slocationResWhatToBring{get;set;}
        @AuraEnabled
        public String slocationResEligibilityDesc{get;set;}
        @AuraEnabled
        public Boolean blocationResSNAP{get;set;}
        @AuraEnabled
        public Boolean blocationResCCAP{get;set;}
        @AuraEnabled
        public Boolean blocationResTANF{get;set;}
        @AuraEnabled
        public Boolean blocationResMedicaid{get;set;}
        @AuraEnabled 
        public String tlocationResMondayOpen{get;set;}
        @AuraEnabled 
        public String tlocationResMondayClose{get;set;}
        @AuraEnabled 
        public String tlocationResTuesdayClose{get;set;}
        @AuraEnabled 
        public String tlocationResTuesdayOpen{get;set;}
        @AuraEnabled 
        public String tlocationResWednesdayClose{get;set;}
        @AuraEnabled 
        public String tlocationResWednesdayOpen{get;set;}
        @AuraEnabled 
        public String tlocationResThursdayClose{get;set;}
        @AuraEnabled 
        public String tlocationResThursdayOpen{get;set;}
        @AuraEnabled 
        public String tlocationResFridayClose{get;set;}
        @AuraEnabled 
        public String tlocationResFridayOpen{get;set;}
        @AuraEnabled 
        public String tlocationResSaturdayClose{get;set;}
        @AuraEnabled 
        public String tlocationResSaturdayOpen{get;set;}
        @AuraEnabled 
        public String tlocationResSundayClose{get;set;}
        @AuraEnabled 
        public String tlocationResSundayOpen{get;set;}
        @AuraEnabled
        public Boolean bIsMondayClosed{get;set;}
        @AuraEnabled
        public Boolean bIsTuesdayClosed{get;set;}
        @AuraEnabled
        public Boolean bIsWednesdayClosed{get;set;}
        @AuraEnabled
        public Boolean bIsThursdayClosed{get;set;}
        @AuraEnabled
        public Boolean bIsFridayClosed{get;set;}
        @AuraEnabled
        public Boolean bIsSaturdayClosed{get;set;}
        @AuraEnabled
        public Boolean bIsSundayClosed{get;set;}
        @AuraEnabled
        public String sDaysLocationClosed{get;set;}
        
        public LocationResourceWrapper(LocationResource__c objResLoc){
            this.sResourceId = objResLoc.Resource__c;
            this.sLocationResourceId = objResLoc.Id;
            this.slocationResOffering = objResLoc.Location__c;
            this.slocationResStatus = objResLoc.Status__c;
            this.slocationResPhone = objResLoc.Phone__c;
            this.slocationResFax = objResLoc.Fax__c;
            this.slocationResTollFree = objResLoc.TollFree__c;
            this.slocationResAgesServed = objResLoc.AgesServed__c;
            this.slocationResEligibilty = objResLoc.EligibilityDescription__c;
            this.slocationResDescription = objResLoc.ResourceDescription__c;
            this.slocationResGeoAgesServed = objResLoc.Geography_Served__c;
            this.slocationResFirstPOCName = objResLoc.FirstPointOfContactName__c;
            this.slocationResFirstPOCTitle = objResLoc.FirstPointOfContactTitle__c;
            this.slocationResFirstPOCPhone = objResLoc.FirstPointofContactPhone__c;
            this.slocationResFirstPOCEmail = objResLoc.FirstPointofContactEmail__c;
            this.slocationResSecondPOCName = objResLoc.SecondPointOfContactName__c;
            this.slocationResSecondPOCTitle = objResLoc.SecondPointOfContactTitle__c;
            this.slocationResSecondPOCEmail = objResLoc.SecondPointofContactEmail__c;
            this.slocationResSecondPOCPhone = objResLoc.SecondPointofContactPhone__c;
            this.blocationResSNAP = objResLoc.EligibilitySNAP__c;
            this.blocationResCCAP = objResLoc.EligibilityCCAP__c;
            this.blocationResTANF  = objResLoc.EligibilityTANF__c;
            this.blocationResMedicaid = objResLoc.EligibilityMedicaid__c;
            this.tlocationResMondayOpen  = String.valueOf(objResLoc.MondayOpen__c);
            this.tlocationResMondayClose  = String.ValueOf(objResLoc.MondayClose__c);
            this.tlocationResTuesdayClose  = String.valueOf(objResLoc.TuesdayClose__c);
            this.tlocationResTuesdayOpen  = String.valueOf(objResLoc.TuesdayOpen__c);
            this.tlocationResWednesdayClose  = String.valueOf(objResLoc.WednesdayClose__c);
            this.tlocationResWednesdayOpen  = String.valueOf(objResLoc.WednesdayOpen__c);
            this.tlocationResThursdayClose  = String.valueOf(objResLoc.ThursdayClose__c);
            this.tlocationResThursdayOpen  = String.valueOf(objResLoc.ThursdayOpen__c);
            this.tlocationResFridayClose  = String.valueOf(objResLoc.FridayClose__c);
            this.tlocationResFridayOpen  = String.valueOf(objResLoc.FridayOpen__c);
            this.tlocationResSaturdayClose  = String.valueOf(objResLoc.SaturdayClose__c);
            this.tlocationResSaturdayOpen  = String.valueOf(objResLoc.SaturdayOpen__c);
            this.tlocationResSundayClose  = String.valueOf(objResLoc.SundayClose__c);
            this.tlocationResSundayOpen  = String.valueOf(objResLoc.SundayOpen__c);
            this.slocationResTimeZone  = objResLoc.TimeZone__c;
            this.slocationResFees  = objResLoc.Fees__c;
            this.slocationResNotes  = objResLoc.Notes__c;
            this.slocationResNextSteps  = objResLoc.NextSteps__c;
            this.slocationResWhatToBring  = objResLoc.WhatToBring__c;
            this.sDaysLocationClosed = objResLoc.DaysClosed__c;
            
        }
    }
    
}