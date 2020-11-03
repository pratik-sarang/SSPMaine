/**
* Class Name    : RE_MyPlanHelper
* Owner         : DELOITTE
* Created Date  : 06/10/2019
* Description   : Helper class for MyPlanCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  06/10/2019  PANKAJ       Initial Version
*  01/07/2020  MEGHA M      Modified Version
**/
public with sharing class RE_MyPlanHelper {
   /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/12/2019
    * @methodname   execute()
    * @description  This methods is used for getting 211 data
    * @param        mapInputData 
    * @return       Map<String, Object> 
    ******************************************************************************************/
    public static Map<String, Object> execute(Map<String, Object> mapInputData) {
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, RE_GoogleMapGeoLocationResponseWrapper.Northeast> mapZipLatLng = new Map<String, RE_GoogleMapGeoLocationResponseWrapper.Northeast>();
        String sMockJsonResponse = RE_GlobalConstants.sMapMockJsonResponse;
        RE_GoogleMapGeoLocationResponseWrapper wrapper = (RE_GoogleMapGeoLocationResponseWrapper) JSON.deserialize(sMockJsonResponse, RE_GoogleMapGeoLocationResponseWrapper.class);        

        if(wrapper.status == RE_GlobalConstants.STATUS_OK){
            for(RE_GoogleMapGeoLocationResponseWrapper.Results r: wrapper.results){
                RE_GoogleMapGeoLocationResponseWrapper.Northeast loc = new RE_GoogleMapGeoLocationResponseWrapper.Northeast();
                loc.lat = r.geometry.location.lat;
                loc.lng = r.geometry.location.lng;
                mapZipLatLng.put(r.address_components[0].long_name, loc);
            }
            mapResponse.put('success', mapResponse);
        }
        return mapResponse;
    }
   /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/12/2019
    * @methodname   getDistance()
    * @description  This methods is used to get the distance between two Locations
    * @param        String title,string description, String recid
    * @return       Double 
    ******************************************************************************************/
    public static Double getDistance(Location firstLocation, Location secondLocation, String unit){
        //return (firstLocation != null && secondLocation != null) ? Location.getDistance(firstLocation, secondLocation, 'mi'):null;
         Double DoubleDistance = (firstLocation != null && secondLocation != null) ? Location.getDistance(firstLocation, secondLocation, 'mi'):null;
         if(DoubleDistance != null){
            Decimal dbl = Decimal.valueOf(DoubleDistance);
            //Double dbl = Double.valueOf('0.'+String.valueOf(DoubleDistance).substringAfter('.'));
            //Double flDouble = Decimal.ValueOf('.'+String.valueOf(Math.round(dbl*10))) + Double.valueOf(String.valueOf(DoubleDistance).substringBefore('.'));
            Double flDouble = dbl.setScale(1, RoundingMode.CEILING);
            return flDouble;
         }
         else{
             return DoubleDistance;
         }
    }
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   getReferralNotes()
    * @description  This methods is used to get the Referral Notes
    * @return       Map<String, List<RE_NotesCtrl.NotesWrapper>> 
    ******************************************************************************************/
    public static Map<String, List<RE_NotesCtrl.NotesWrapper>> getReferralNotes(Set<Id> setReferralIds){
        Map<String, ContentDocumentLink> mapContentIdContentDocumentLink = new Map<String, ContentDocumentLink>();
        Map<String, RE_NotesCtrl.NotesWrapper> mapLinkedContentNotes = new Map<String, RE_NotesCtrl.NotesWrapper>();
        Map<String, ContentNote> mapEntityLinkedContentNotes = new Map<String, ContentNote>();
        Map<String, List<RE_NotesCtrl.NotesWrapper>> mapReferralContentNotes = new Map<String, List<RE_NotesCtrl.NotesWrapper>>();
        
        Set<Id> setContentDocumentIds = new Set<Id>();
        String sFieldsApiName = RE_DataBaseQueryFields.sContentDocumentFieldsApiName;
        String sWhereClause = RE_DataBaseQueryFields.sContentDocumentWhereClause;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentDocumentLink', sFieldsApiName, mapQueryParameters);
        String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
        //Updated by Payal to query notes related to other organizations-ONEVIEW-1373
        List<ContentDocumentLink> lstdocumentlink =RE_SharingByPassCtrl.getContentDocumentLinks(sQuery,setReferralIds); 
        for (ContentDocumentLink objContentDocLink : lstdocumentlink) {
            setContentDocumentIds.add(objContentDocLink.ContentDocumentId);
            mapContentIdContentDocumentLink.put(objContentDocLink.ContentDocumentId, objContentDocLink);
        }
        
        List<RE_NotesCtrl.NotesWrapper> lstnotes = new List<RE_NotesCtrl.NotesWrapper>();
        sFieldsApiName = RE_DataBaseQueryFields.sContentNotesFieldsApiName;
        sWhereClause = RE_DataBaseQueryFields.sContentNotesWhereClause;
        
        Map<String, String> mapQueryParametersForContentNote = new Map<String, String>();
        mapQueryParametersForContentNote.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapQueryParametersForContentNote.put(RE_GlobalConstants.sLimitKey, '50000');
        mapQueryParametersForContentNote.put(RE_GlobalConstants.sOrderByKey, sOrderby);
        sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentNote', sFieldsApiName, mapQueryParametersForContentNote);
      
        List<ContentNote> lstContentNotes = RE_SharingByPassCtrl.getContentNotes(sQuery, setContentDocumentIds);
            //Database.query(sQuery);
        Map<String,Boolean> mapCNoteAccess = RE_NotesHelper.getNotesPublicOrPrivateFromContentVersion(lstContentNotes);
        for (ContentNote objContentNote : lstContentNotes) {
            Blob noteContent = objContentNote.Content;
            String sContentAsString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(noteContent)).toString();                     
            String requiredString = sContentAsString.subString(sContentAsString.indexOf('<p>') + 3, sContentAsString.indexOf('</p>'));
            RE_NotesCtrl.NotesWrapper obj = new RE_NotesCtrl.NotesWrapper(objContentNote.Id, objContentNote.Title, requiredString, objContentNote.CreatedBy.Name, objContentNote.createddate, objContentNote.LastModifiedDate, objContentNote.LastModifiedBy.Name);
            obj.CreatedDayTime = GeneralUtility.getFormatedDate(String.valueOf(obj.CreatedDate));
            obj.isPublic = (mapCNoteAccess != null && mapCNoteAccess.containsKey(objContentNote.Id) ? mapCNoteAccess.get(objContentNote.Id) : false);
            mapLinkedContentNotes.put(objContentNote.Id, obj);
        }
        
        for(String contentDocumentId : mapContentIdContentDocumentLink.keySet()){
            if(mapReferralContentNotes.containsKey(mapContentIdContentDocumentLink.get(contentDocumentId).LinkedEntityId)){
                List<RE_NotesCtrl.NotesWrapper> lstContent = mapReferralContentNotes.get(mapContentIdContentDocumentLink.get(contentDocumentId).LinkedEntityId);
                lstContent.add(mapLinkedContentNotes.get(contentDocumentId));
                mapReferralContentNotes.put(mapContentIdContentDocumentLink.get(contentDocumentId).LinkedEntityId, lstContent);
            }else{
                List<RE_NotesCtrl.NotesWrapper> lstCont = new List<RE_NotesCtrl.NotesWrapper>();
                lstCont.add(mapLinkedContentNotes.get(contentDocumentId));
                mapReferralContentNotes.put(mapContentIdContentDocumentLink.get(contentDocumentId).LinkedEntityId, lstCont);
            }
        }
        return mapReferralContentNotes; 
    }
    
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019O
    * @methodname   getLocationOperatingHours()
    * @description  This methods is used to get the Location Operating hours
    * @return       Map<String, String>> 
    ******************************************************************************************/
   /* public static Map<Id,  Map<String, String>> getLocationOperatingHours(Set<Id> lstLocations){
        return RE_SharingByPassCtrl.getLocationOperatingHours(lstLocations);
    }*/    
    /********************************************************************************************
    * @author       Pankaj
    * @date         07/17/2019
    * @methodname   getLocationResources()
    * @description  This methods is used to get the locaion resources
    * @return       List<LocationResource__c>
    **********************************************************************************************/
    public static List<LocationResource__c> getLocationResources(Set<Id> setResourceIds, Set<Id> setLocationIds){
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        Boolean bSuccess = false;
        List<LocationResource__c> lstFav = new List<LocationResource__c>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        List<LocationResource__c> lstLocationResources = new List<LocationResource__c>();
        String sFieldsTobeQueryOnLocationResource = RE_DataBaseQueryFields.sFieldsTobeQueryOnLocationResource;
        String sWhereClauseOnLocationResource = RE_DataBaseQueryFields.sWhereClauseOnLocationResource;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocationResource);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c', sFieldsTobeQueryOnLocationResource, mapQueryParameters);
        try{
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    lstLocationResources = RE_SharingByPassCtrl.getLocationResources(sQuery,setResourceIds,setLocationIds); 
                }
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanHelper','getLocationResources',e.getStackTraceString(), true);
        }
        return lstLocationResources;
    } 
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   getLocationOperatingHours()
    * @description  This methods is used to get the Location Operating hours
    * @return       Map<String, String>> 
    ******************************************************************************************/
    public static Map<Id,  Map<String, String>>  getLocationOperatingHours(Set<Id> lstLocations){
        Map<Id,  Map<String, String>> mapLocationOperatingHours = new Map<Id,  Map<String, String>>();
        try{
            List<Location__c> lstLocation = RE_SharingByPassCtrl.getLocationOperatingHours(lstLocations);
            for(Location__c loc : lstLocation){
                Map<String, String> mapdata = new Map<String, String>();
                String sundayOpenClose = (loc.SundayOpen__c != null && loc.SundayClose__c != null) ? GeneralUtility.getOperatingHours(loc.SundayOpen__c)+' ## '+GeneralUtility.getOperatingHours(loc.SundayClose__c):'';
                String mondayOpenClose = (loc.MondayOpen__c != null && loc.MondayClose__c != null) ? GeneralUtility.getOperatingHours(loc.MondayOpen__c)+' ## '+GeneralUtility.getOperatingHours(loc.MondayClose__c):'';
                String tuesOpenClose = (loc.TuesdayOpen__c != null && loc.TuesdayClose__c != null) ? GeneralUtility.getOperatingHours(loc.TuesdayOpen__c)+' ## '+GeneralUtility.getOperatingHours(loc.TuesdayClose__c):'';
                String wednesdayOpenClose = (loc.WednesdayOpen__c != null && loc.WednesdayClose__c != null) ? GeneralUtility.getOperatingHours(loc.WednesdayOpen__c)+' ## '+GeneralUtility.getOperatingHours(loc.WednesdayClose__c):'';
                String thursdayOpenClose = (loc.ThursdayOpen__c != null && loc.ThursdayClose__c != null) ? GeneralUtility.getOperatingHours(loc.ThursdayOpen__c)+' ## '+GeneralUtility.getOperatingHours(loc.ThursdayClose__c):'';
                String fridayOpenClose = (loc.FridayOpen__c != null && loc.FridayClose__c != null) ? GeneralUtility.getOperatingHours(loc.FridayOpen__c)+' ## '+GeneralUtility.getOperatingHours(loc.FridayClose__c):'';
                String saturdayOpenClose = (loc.SaturdayOpen__c != null && loc.SaturdayClose__c != null) ? GeneralUtility.getOperatingHours(loc.SaturdayOpen__c)+' ## '+GeneralUtility.getOperatingHours(loc.SaturdayClose__c):'';
                mapdata.put('LocationName', loc.Name);
                mapdata.put('Sunday', sundayOpenClose);
                mapdata.put('Monday', mondayOpenClose);
                mapdata.put('Tuesday', tuesOpenClose);
                mapdata.put('Wednesday', wednesdayOpenClose);
                mapdata.put('Thursday', thursdayOpenClose);
                mapdata.put('Friday', fridayOpenClose);
                mapdata.put('Saturday', saturdayOpenClose);
                mapLocationOperatingHours.put(loc.Id, mapdata);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_MyPlanHelper','getLocationOperatingHours',e.getStackTraceString(), true);
        }
        return mapLocationOperatingHours;
    }
    /**************************************************************************************
    * @author       Megha Mittal
    * @date         01/07/2020
    * @methodname   getShareMyPlanEmailTemplateBody()
    * @description  This methods is used to set the email body for my plan email
    * @return       String
    ******************************************************************************************/
    public static String getShareMyPlanEmailTemplateBody(List<RE_MyPlanWrapper.EmailWrapper> lstResources){             
        String sResourceDetails =  RE_GlobalConstants.sEmptyString; 
        String sTemplateBody = RE_GlobalConstants.sEmptyString;
        for(RE_MyPlanWrapper.EmailWrapper resource : lstResources){
            sResourceDetails = RE_GlobalConstants.sSharingMyPlanStaticStyling+resource.sResourceName;
            sResourceDetails+=(resource.sReferralOrgName !=null && resource.sReferralOrgName !='')?'</b><br>'+resource.sReferralOrgName:'</b>';
            sResourceDetails+=(resource.sLocationAddress1 !=null && resource.sLocationAddress1 !='')?'<br>'+resource.sLocationAddress1:'';
            sResourceDetails+=(resource.sLocationAddress2 !=null && resource.sLocationAddress2 !='')?'<br>'+resource.sLocationAddress2:'';                                    
            String sAddressLine = resource.sLocationCity+', '+resource.sLocationState+' '+resource.sLocationZip+' '+resource.sLocationZipExt;
            String sAddressFinal='';            
            for(String sPart : sAddressLine.split(',') ){                                
                sAddressFinal+=(sPart!=null && sPart!='' && sPart.trim()!='null')?sPart+',':'';
            }
            if(sAddressFinal.endsWith(',')){
                sAddressFinal = sAddressFinal.removeEnd(',');
            }
            
            sResourceDetails+=(sAddressFinal !=null && sAddressFinal !='')?'<br>'+sAddressFinal:'';
            sResourceDetails+='<br>'+Label.phone+': '+resource.sPOCPhone+'<br>'+Label.email+': '+resource.sPOCEmail+'<br>'+Label.Website+': '+resource.sReferralOrgUrl;
            sResourceDetails+='<br>'+Label.HoursOfOperationHeader+': '+resource.sOperatingHoursToday+'</div><p>';
            sTemplateBody += sResourceDetails;
        }
        return sTemplateBody;
    }
}