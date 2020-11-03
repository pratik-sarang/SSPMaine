/*
* Class Name    	: RE_LocationCtrl
* Owner             : DELOITTE
* Created Date      : 05/02/2019
* Description       : Controller class for Re_Location Component. 

**/

public with Sharing class RE_LocationCtrl {
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   getLocationDetails
    * @description  This methods is used to get the Location Details for the Specific record
    * @param        sRecordId   (String)   : Location record Id
    * @return       String (Json String fro Location record)
    ********************************************************************************************/
    
    @AuraEnabled
    public Static RE_CreateLightningServerResponse getLocationDetails(String strRecordId) {
        
        String sRecordId = String.escapeSingleQuotes(strRecordId);
        GeneralUtility.isAuthenticatedUser();
        String sResult;
        Boolean bSuccess = false;
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        Id locationRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Location__c','Location');
        try{
            if (sRecordId != null) {
                List<Schema.PicklistEntry> lstStatusOptions = Location__c.Status__c.getDescribe().getPicklistValues();
                
                List<Schema.PicklistEntry> lstStatePicklistOptions = Location__c.State__c.getDescribe().getPicklistValues();
                List<PicklistWrapper> lstStateOptions = new List<PicklistWrapper>();
                lstStateOptions.add(new PicklistWrapper('None',null,false));
                for(Schema.PicklistEntry itrStatus : lstStatePicklistOptions){
                    lstStateOptions.add(new PicklistWrapper(itrStatus.getLabel(),itrStatus.getValue(),false));
                }
                List<Schema.PicklistEntry> lstPicklistTimeZoneOptions = Location__c.TimeZone__c.getDescribe().getPicklistValues();
            List<PicklistWrapper> lstTimeZoneOptions = new List<PicklistWrapper>();
            lstTimeZoneOptions.add(new PicklistWrapper('None',null,true));
            for(Schema.PicklistEntry itrStatus : lstPicklistTimeZoneOptions){
                lstTimeZoneOptions.add(new PicklistWrapper(itrStatus.getLabel(),itrStatus.getValue(),false));
            }
                
                
                String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnLocationCtrl;
                
                String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnLocationCtrl;
                String sQuery;
                Map<String,String> mapQueryParameters = new Map<String,String>();
                // String sOrderby = 'CreatedDate ASC';
                String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
                mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
                
                Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility('Location__c',sFieldsApiName,mapQueryParameters);
                
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                           
                switch on (switchCaseKey) {
                    when SWITCH_SUCCESS {
                       sQuery =  mapResponse.get(true);
                       List<Location__c> lstLocations = Database.query(sQuery); 
                        if (lstLocations != null) {
                            bSuccess = true;
                            mapResult.put('result',JSON.serialize(new locationWrapper(lstLocations[0])));
                             mapResult.put('lstStatusOptions',JSON.serialize(lstStatusOptions));
                              mapResult.put('lstStateOptions',JSON.serialize(lstStateOptions));
                            mapResult.put('lstTimeZoneOptions',JSON.serialize(lstTimeZoneOptions));
                            //sResult = JSON.serialize(lstLocations[0]);
                        } 
                        } 
                    when SWITCH_FAILURE {
                        bSuccess = false;
                        errorMap.put('error', 'Field access error.');
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','getLocationDetails','Some Fields doesn\'t have the required access :: '+mapResponse.get(false), true);
                    }
                    }
            }
        } 
        catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','getLocationDetails',e.getMessage(),true);
        } 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResult); 
    }
    
/********************************************************************************************
* @author       Lagan Kankane
* @date         07/23/2019
* @methodname   fetchInitData
* @description  This methods is used fetch the Init Data for New Location Page
* @param        sRecordId : AccountId of the Account to which the location is being added.
* @return       RE_CreateLightningServerResponse: locationWrapper , Picklist values fo page load
********************************************************************************************/
    
    @AuraEnabled
    public Static RE_CreateLightningServerResponse fetchInitData(String strRecordId) {
        String sRecordId = String.escapeSingleQuotes(strRecordId);
        GeneralUtility.isAuthenticatedUser();
        String sResult;
        Boolean bSuccess = false;
        Map<String, Object> mapResult = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        Id locationRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Location__c','Location');
        
        try{
            
            List<locationWrapper> lstLocation = new List<locationWrapper>();
            lstLocation.add(new locationWrapper(sRecordId));
            
            List<Schema.PicklistEntry> lstPicklistTimeZoneOptions = Location__c.TimeZone__c.getDescribe().getPicklistValues();
            List<PicklistWrapper> lstTimeZoneOptions = new List<PicklistWrapper>();
            lstTimeZoneOptions.add(new PicklistWrapper('None',null,true));
            for(Schema.PicklistEntry itrStatus : lstPicklistTimeZoneOptions){
                lstTimeZoneOptions.add(new PicklistWrapper(itrStatus.getLabel(),itrStatus.getValue(),false));
            }
            
            List<Schema.PicklistEntry> lstStatusOptions = Location__c.Status__c.getDescribe().getPicklistValues();
            
            List<Schema.PicklistEntry> lstStatePicklistOptions = Location__c.State__c.getDescribe().getPicklistValues();
            List<PicklistWrapper> lstStateOptions = new List<PicklistWrapper>();
            lstStateOptions.add(new PicklistWrapper('None',null,true));
            for(Schema.PicklistEntry itrStatus : lstStatePicklistOptions){
                lstStateOptions.add(new PicklistWrapper(itrStatus.getLabel(),itrStatus.getValue(),false));
            }
            List<Schema.PicklistEntry> lstDaysLocationClosedOptions = Location__c.DaysLocationClosed__c.getDescribe().getPicklistValues();
            mapResult.put('lstTimeZoneOptions',JSON.serialize(lstTimeZoneOptions));
            mapResult.put('lstStatusOptions',JSON.serialize(lstStatusOptions));
            mapResult.put('lstStateOptions',JSON.serialize(lstStateOptions));
            mapResult.put('lstDaysLocationClosedOptions',JSON.serialize(lstDaysLocationClosedOptions));
            mapResult.put('objLocation',JSON.serialize(lstLocation[0]));
            bSuccess = true;
        } 
        catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','fetchInitData',e.getMessage(),true);
        } 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResult); 
    }
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         05/02/2019
* @methodname   saveLocation
* @description  This methods is used to save the Location Details for the Specific record
* @param        sLocationJson   (String)   : Location record JSON
* @return       null
********************************************************************************************/
    @AuraEnabled
    public Static RE_CreateLightningServerResponse saveLocation(String strLocationJson, Boolean bDisplayAnnouncement){  
        
        GeneralUtility.isAuthenticatedUser();
        //Commented as par of defect 344551:R1 Backyard: Unable to modify and save location details for resources as CP Admin
       // String sLocationJson = String.escapeSingleQuotes(strLocationJson);
       	  String sLocationJson = strLocationJson.replace( '\\', '\\' );
       
        String sResult;
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        try {
            if (strLocationJson != null && !String.isBlank(strLocationJson)) {
                
                locationWrapper retVal = (locationWrapper) JSON.deserialize(sLocationJson, locationWrapper .class);
                //
               //As part of defect  344551:R1 Backyard: Unable to modify and save location details for resources as CP Admin
                // String LocId = retVal.sId;
                String LocId =   String.escapeSingleQuotes(retVal.sId);
                //Changes for fetching the existing fields to be modified later
               /* Location__c oldLocationObj = [select MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,
                                              ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,
                                              SundayOpen__c,SundayClose__c from Location__c where id =: retVal.sId];*/
                 Location__c oldLocationObj;
                
                //----
        String sFieldsApiNamesForDays = RE_DataBaseQueryFields.sDaysFieldsQueryLocation;       
        String sWhereClauseForDays = RE_DataBaseQueryFields.sWhereClauseForDays ;
        String sQuery;
        Map<String,String> mapQueryParameters = new Map<String,String>();
        // String sOrderby = 'CreatedDate ASC';
        String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForDays);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
        
        Map<Boolean,String> mapLocation = RE_DataAccessChecker.getFieldsAccessibility('Location__c',sFieldsApiNamesForDays,mapQueryParameters);
        if(mapLocation.get(true) != null){
            sQuery =  mapLocation.get(true);
            oldLocationObj = Database.query(sQuery);
            
        }else{
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_LocationCtrl','saveLocation','***FLS Violation***'+mapLocation.get(false),true);
        }
                
                
                //--
                //
                
                
                Location__c objLocation = new Location__c();
                objLocation.Id = retVal.sId;
                objLocation.Name = retVal.sName;
                objLocation.Address1__c = retVal.sAddress1;
                objLocation.Address2__c = retVal.sAddress2;
                objLocation.City__c = retVal.sCity;
                objLocation.County__c = retVal.sCounty;
                objLocation.DaysLocationClosed__c = retVal.sDaysLocationClosed;
                objLocation.Description__c = retVal.sDescription;
                objLocation.ParkingInstructions__c = retVal.sParkingInstructions;
                objLocation.SpecialLocationInstructions__c = retVal.sSpecialLocationInstructions;
                objLocation.PointofContactEmail__c = retVal.sPointofContactEmail;
                objLocation.PointOfContactName__c = retVal.sPointofContactName;
                objLocation.PointofContactPhone__c = retVal.sPointofContactPhone;
                objLocation.POCPhoneExt__c = retVal.sPointofContactPhoneExt;
                objLocation.SpecialAnnouncements__c = retVal.sSpecialAnnouncements;
                objLocation.Status__c = retVal.sStatus;
                objLocation.State__c = retVal.sState;
                objLocation.Zip__c = retVal.sZip;
                objLocation.Phone__c = retVal.sPointofContactPhone;
                objLocation.TimeZone__c = retVal.sTimeZone;
                objLocation.TransportationInstructions__c = retVal.sTransportationInstructions;
                objLocation.Language__c = retVal.sLanguage;
                objLocation.AnnouncementStatus__c = retVal.bAnnouncementStatus;
                objLocation.Notes__c = retVal.sNotes;
                objLocation.Email__c = retVal.email;
                objLocation.Phone__c =  retVal.phone;
                objLocation.LocationWebsite__c = retVal.url;
                if(retVal.tMondayClose != null ){//&& retVal.tMondayClose != String.valueOf(oldLocationObj.MondayClose__c)){
                    objLocation.MondayClose__c= convertToLocalTime(retVal.tMondayClose); 
                }
               else{
                    objLocation.MondayClose__c = null;// retVal.tMondayClose;
                }
                if(retVal.tMondayOpen != null){// && retVal.tMondayOpen != String.valueOf(oldLocationObj.MondayOpen__c )){
                    objLocation.MondayOpen__c = convertToLocalTime(retVal.tMondayOpen);
                }
               else{
                    objLocation.MondayOpen__c = null;//  retVal.tMondayOpen;
                }
                if(retVal.tSaturdayClose != null){// && retVal.tSaturdayClose != String.valueOf(oldLocationObj.SaturdayClose__c )){
                    objLocation.SaturdayClose__c =  convertToLocalTime(retVal.tSaturdayClose);
                }
                else{
                    objLocation.SaturdayClose__c =  null;// retVal.tSaturdayClose;
                }
                if(retVal.tSaturdayOpen != null){// && retVal.tSaturdayOpen != String.valueOf(oldLocationObj.SaturdayOpen__c)){
                    objLocation.SaturdayOpen__c = convertToLocalTime(retVal.tSaturdayOpen);
                }
                else{
                    objLocation.SaturdayOpen__c =  null;// retVal.tSaturdayOpen;
                }
                if(retVal.tSundayClose != null){// && retVal.tSundayClose != String.valueOf(oldLocationObj.SundayClose__c)){
                    objLocation.SundayClose__c = convertToLocalTime(retVal.tSundayClose);
                }
               else{
                    objLocation.SundayClose__c =  null;// retVal.tSundayClose;
                }
                if(retVal.tSundayOpen != null){// && retVal.tSundayOpen != oldLocationObj.SundayOpen__c){
                    objLocation.SundayOpen__c = convertToLocalTime(retVal.tSundayOpen);
                }
                else{
                    objLocation.SundayOpen__c = null;//  retVal.tSundayOpen;
                }
                if(retVal.tThursdayClose != null ){//&& retVal.tThursdayClose != oldLocationObj.ThursdayClose__c){
                    objLocation.ThursdayClose__c = convertToLocalTime(retVal.tThursdayClose);
                }
                else{
                    objLocation.ThursdayClose__c =  null;// retVal.tThursdayClose;
                }
                if(retVal.tThursdayOpen != null ){//&& retVal.tThursdayOpen != oldLocationObj.ThursdayOpen__c){
                    objLocation.ThursdayOpen__c = convertToLocalTime(retVal.tThursdayOpen);
                }
               else{
                    objLocation.ThursdayOpen__c =  null;// retVal.tThursdayOpen;
                }
                if(retVal.tTuesdayClose != null){// && retVal.tTuesdayClose != oldLocationObj.TuesdayClose__c){
                    objLocation.TuesdayClose__c = convertToLocalTime(retVal.tTuesdayClose);
                }
                else{
                    objLocation.TuesdayClose__c =  null;// retVal.tTuesdayClose;
                }
                if(retVal.tTuesdayOpen != null){// && retVal.tTuesdayOpen != oldLocationObj.TuesdayOpen__c){
                    objLocation.TuesdayOpen__c = convertToLocalTime(retVal.tTuesdayOpen);
                }
               else{
                    objLocation.TuesdayOpen__c =  null;// retVal.tTuesdayOpen;
                }
                if(retVal.tWednesdayClose != null){// && retVal.tWednesdayClose != oldLocationObj.WednesdayClose__c){
                    objLocation.WednesdayClose__c = convertToLocalTime(retVal.tWednesdayClose);
                }
                else{
                    objLocation.WednesdayClose__c = null;//  retVal.tWednesdayClose;
                }
                if(retVal.tWednesdayOpen != null ){//&& retVal.tWednesdayOpen != oldLocationObj.WednesdayOpen__c){
                    objLocation.WednesdayOpen__c = convertToLocalTime(retVal.tWednesdayOpen);
                }
                else{
                    objLocation.WednesdayOpen__c =  null;// retVal.tWednesdayOpen;
                }
                if(retVal.tThursdayClose != null){// && retVal.tThursdayClose != oldLocationObj.ThursdayClose__c){
                    objLocation.ThursdayClose__c = convertToLocalTime(retVal.tThursdayClose);
                }
               else{
                    objLocation.ThursdayClose__c = null;//  retVal.tThursdayClose;
                }
                if(retVal.tThursdayOpen != null){// && retVal.tThursdayOpen != oldLocationObj.ThursdayOpen__c){
                    objLocation.ThursdayOpen__c = convertToLocalTime(retVal.tThursdayOpen);
                }
                else{
                    objLocation.ThursdayOpen__c =  null;// retVal.tThursdayOpen;
                }
                if(retVal.tFridayClose != null){// && retVal.tFridayClose != oldLocationObj.FridayClose__c){
                    objLocation.FridayClose__c = convertToLocalTime(retVal.tFridayClose);
                }
                else{
                    objLocation.FridayClose__c =  null;// retVal.tFridayClose;
                }
                if(retVal.tFridayOpen != null){// && retVal.tFridayOpen != oldLocationObj.FridayOpen__c){
                    objLocation.FridayOpen__c = convertToLocalTime(retVal.tFridayOpen);
                }
                else{
                    objLocation.FridayOpen__c =  null;// retVal.tFridayOpen;
                }
                
                if(objLocation != null){
                    objLocation.LocationType__c = retVal.bIsPrimary ? RE_GlobalConstants.sLocationTypeHead : RE_GlobalConstants.sLocationTypeNonHead;
                    
                    RE_DataAccessChecker.updateObject(Location__c.getSObjectType(),objLocation);
                    
                    bSuccess = true;
                    
                }
            }
        } catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_LocationCtrl','saveLocation',e.getMessage(),true);

        }
        
       return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   getFiles
    * @description  This methods is used to get all the Salesforce Files related to Location 
    record displayed 
    * @param        sParentId   (String)   : Location record Id
    * @return       List<ContentDocument> -  list of Content Documents
    ********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getFiles(String strParentId){
        
        String sParentId = String.escapeSingleQuotes(strParentId);
        GeneralUtility.isAuthenticatedUser();
        List<String> lstConDocIds = new List<String>();
        List<ContentDocument> lstConDocs = new List<ContentDocument>(); 
        
        //String sFieldsApiName = 'ContentDocumentId';  Commented by Lagan
        String sFieldsApiName = RE_GlobalConstants.strFieldsApiNameContentDocId;
        
        // String sWhereClause = 'LinkedEntityId =: sParentId';  Commented by Lagan
        String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnLocationCtrl_RE_CreateLightningServerResponse;
        Id sDocumentRecordType = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('DocumentDetail__c','RE_Documents');
        Map<String, Object> mapResult = new Map<String, Object>();
        Boolean bSuccess;
        Map<String, Object> errorMap = new Map<String, Object>();
        try{
            Map<String,String> mapQueryParameters = new Map<String,String>();
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '500');
            //Added by LK
            String ContentDocumentLink = RE_GlobalConstants.strFieldsApiNameContentDocumentLink;
            //

            // String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentDocumentLink',sFieldsApiName,mapQueryParameters); Commented by LK
            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(ContentDocumentLink,sFieldsApiName,mapQueryParameters);
            for (ContentDocumentLink conDocLink : Database.query(sQuery)) { //[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:sParentId]){
                lstConDocIds.add(conDocLink.ContentDocumentId);
            }
            
            //Added by LK
            sFieldsApiName = RE_DataBaseQueryFields.sQueryRE_CreateLightningServerResponse;
            sWhereClause = RE_DataBaseQueryFields.strWhereClauseOnLocationCtrl_RE_CreateLightningServerResponse;
            
            //   
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '500');
            
            //  sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentDocument',sFieldsApiName,mapQueryParameters); Commented by LK
            
            //Added by LK
            sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strContentDocument,sFieldsApiName,mapQueryParameters);
            //
            
            //List<ContentDocument> lstConDocs = [select Id,Title,FileType,CreatedDate,ContentSize,Description from ContentDocument WHERE Id IN:lstConDocIds];
            lstConDocs = Database.query(sQuery);
            
            //Code Starts-  Modification for User Story 532
            
      
            //Added by LK
            String sDcoDetailsFields = RE_DataBaseQueryFields.strsDcoDetailsFields;
            String sDocDetailWhereClause = RE_DataBaseQueryFields.sDocDetailWhereClause;
            //
            
            Map<String,String> mapQueryParametersDocDetail = new Map<String,String>();
            
            mapQueryParametersDocDetail.put(RE_GlobalConstants.sWhereClauseKey, sDocDetailWhereClause);
            mapQueryParametersDocDetail.put(RE_GlobalConstants.sLimitKey, '500');
            String sQueryDoc;
            Map<String,String> mapFileIDVsDocTypes = new Map<String,String>();
            // Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility('DocumentDetail__c',sDcoDetailsFields,mapQueryParametersDocDetail);
            Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strDocumentAPIame,sDcoDetailsFields,mapQueryParametersDocDetail);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                           
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQueryDoc =  mapResponse.get(true);

                    List<Schema.PicklistEntry> lstDocTypePicklistOptions = DocumentDetail__c.DocumentType__c.getDescribe().getPicklistValues();
                    Map<String, String> lstDocTypeOptionsMap = new Map<String, String>();
                    for(Schema.PicklistEntry itrDocType : lstDocTypePicklistOptions){
                        lstDocTypeOptionsMap.put(itrDocType.getValue(), itrDocType.getLabel());       
                    }     
                    for(DocumentDetail__c objDocDet : Database.query(sQueryDoc)){
                        mapFileIDVsDocTypes.put(objDocDet.FileId__c, lstDocTypeOptionsMap.get(objDocDet.DocumentType__c));
                    } 
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','getLocationDetails','Some Fields doesn\'t have the required access :: '+mapResponse.get(false), true);
                }
            }

            List<fileWrapper> lstFileWrapper = new List<fileWrapper>();
            for(ContentDocument objConDoc  : lstConDocs){

                if(mapFileIDVsDocTypes.get(objConDoc.Id) != null ){
                    fileWrapper objWrapper = new fileWrapper(objConDoc,mapFileIDVsDocTypes.get(objConDoc.Id),'');
                    lstFileWrapper.add(objWrapper);

                }
            }
             
            bSuccess = true;
            mapResult.put('lstFileWrapper', lstFileWrapper);
            mapResult.put('lstConDocs', lstConDocs);
           

            //Code Ends-  Modification for User Story 532
            
        } 
        catch(Exception e) {
            
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 
                                             'RE_LocationCtrl',
                                             'getFiles', 
                                             e.getMessage(), 
                                             true); 
        }
        
        
          return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResult); 
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   deleteFiles
    * @description  This methods is used to delete Files related to Location record.  
    * @param        sContDocId   (String)   : ContentDocument record Id
    * @return       null
    **********************************************************************************************/    
    @AuraEnabled
    public static RE_CreateLightningServerResponse deleteFiles(String strContDocId) {  
        
        String sContDocId = String.escapeSingleQuotes(strContDocId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        if (sContDocId != null && !String.isBlank(sContDocId)){
            try {
                List<Schema.SObjectType> documentType = new Schema.SObjectType[] {ContentDocument.SObjectType};
        		/*fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(documentType);
                uow.registerDeleted([SELECT Id FROM ContentDocument WHERE Id =: sContDocId]);
                uow.commitWork(); */
                
                Map<String,String> mapQueryParameters = new Map<String,String>();
                /* Commented by LK
                String sFieldsApiName = 'Id';
                String sWhereClause = 'Id =: sContDocId';
*/
                String sFieldsApiName = RE_DataBaseQueryFields.sfieldsConDoc;
                String sWhereClause = RE_DataBaseQueryFields.sWhereClauseIdInCont;
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
                
                // String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentDocument',sFieldsApiName,mapQueryParameters);  
                String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strContentDocument,sFieldsApiName,mapQueryParameters);  
                ContentDocument objContentDocument = Database.query(sQuery);
                Database.DeleteResult srCD ;
                srCD = Database.delete(objContentDocument,false);
                if (!srCD.isSuccess()){ 
                    //String msg = '';
                    String msg = RE_GlobalConstants.sEmptyString;
                    for(Database.Error err : srCD.getErrors()) {
                        bSuccess = false;
                        errorMap.put('error', err.getMessage());
                        msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                    }
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_FileUploadController','deleteFiles + ContentDocument',msg,false);
                }
                
                if(RE_DataAccessChecker.isAllowedToDelete(DocumentDetail__c.getSObjectType())){
                    /*sFieldsApiName = 'Id, FileId__c';
sWhereClause = 'FileId__c =: sContDocId';*/
                    
                    sFieldsApiName = RE_DataBaseQueryFields.sFieldsApiName_LocationCtrl;
                    sWhereClause = RE_DataBaseQueryFields.sFieldsIsContactId;
                    
                	mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
                    // sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('DocumentDetail__c',sFieldsApiName,mapQueryParameters); Commented by LK
                    sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strDocumentAPIame,sFieldsApiName,mapQueryParameters);
                    DocumentDetail__c objDdetail = Database.query(sQuery);
                    RE_DataAccessChecker.deleteObject(DocumentDetail__c.getSObjectType(),objDdetail);
                    bSuccess = true;
                                    //Database.DeleteResult srDD ;
                                    //srDD = Database.delete(objDdetail,false);
                                    /*if (!srDD.isSuccess()){ 
                        String msg = '';
                        for(Database.Error err : srDD.getErrors()) {
                            msg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        }
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_FileUploadController','deleteFiles + DocumentDetail__c',msg,false);
                } */
                    
                    
                }
                /*documentType = new Schema.SObjectType[] {DocumentDetail__c.SObjectType};
        		uow = new fflib_SObjectUnitOfWork(documentType);
                uow.registerDeleted([SELECT Id, FileId__c FROM DocumentDetail__c WHERE FileId__c =: sContDocId]);
                uow.commitWork();*/
                
                
                //delete [SELECT Id, FileId__c FROM DocumentDetail__c WHERE FileId__c =: sContDocId];
            } catch (Exception e) {
                bSuccess = false;
                errorMap.put('error', e.getMessage());
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','deleteFiles', e.getMessage(),true);
            }            
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   isReadOnly
    * @description  This methods is used to check if the logged in User have only Readonly Access.  
    * @param        sContDocId   (String)   : ContentDocument record Id
    * @return       boolean value 
    ********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse isReadOnly() {  
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        Schema.sObjectType locationType = Location__c.sObjectType;// Returns token for the Location object
        try{
            Boolean bCanUpdate = RE_DataAccessChecker.isAllowedToUpdate(locationType);
            // return bCanUpdate;
            bSuccess = true;
			//[Suresh] defect #392972
			boolean isAdmin = true;
			String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
			if(selectedRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF || selectedRole == RE_GlobalConstants.CASE_WORKER){
				isAdmin = false;
			}
            
			mapResponse.put('canUpdate', isAdmin);//RE_DataAccessChecker.isAllowedToUpdate(locationType));
            
        } catch (Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LocationCtrl','isReadOnly',e.getMessage(),true);
            // return null;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    public class fileWrapper {
        
        @AuraEnabled public String sDocType;
        @AuraEnabled public ContentDocument objConDoc;
        @AuraEnabled public String sDistributionPublicUrl;
        
        public fileWrapper(ContentDocument objConDoc , String sDocType , String sDistributionPublicUrl){
            this.sDocType = sDocType;
            this.objConDoc = objConDoc; 
            this.sDistributionPublicUrl = sDistributionPublicUrl;
        }
        
    }
	
	/********************************************************************************************
* @author       Lagan Kankane
* @date         07/24/2019
* @methodname   locationWrapper
* @description  Wrapper for Location Object
********************************************************************************************/
    
    public class locationWrapper {
        
        @AuraEnabled 
        public String sLocationId{get;set;}
        @AuraEnabled 
        public String sStatus{get;set;}
        @AuraEnabled 
        public String sName{get;set;}
        @AuraEnabled 
        public String sPointofContactPhone{get;set;}
        @AuraEnabled 
        public String sPointofContactPhoneExt{get;set;}
        @AuraEnabled 
        public String sPointofContactEmail{get;set;}
        @AuraEnabled 
        public String sPointofContactName{get;set;}
        @AuraEnabled 
        public String tSaturdayClose{get;set;}
        @AuraEnabled 
        public String tSaturdayOpen{get;set;}
        @AuraEnabled 
        public String sSpecialAnnouncements{get;set;}
        @AuraEnabled 
        public String sSpecialLocationInstructions{get;set;}
        @AuraEnabled 
        public String sState{get;set;}
        @AuraEnabled 
        public String tSundayClose{get;set;}
        @AuraEnabled 
        public String tSundayOpen{get;set;}
        @AuraEnabled 
        public String tThursdayClose{get;set;}
        @AuraEnabled 
        public String tThursdayOpen{get;set;}
        @AuraEnabled 
        public String sTransportationInstructions{get;set;}
        @AuraEnabled 
        public String tTuesdayClose{get;set;}
        @AuraEnabled 
        public String tTuesdayOpen{get;set;}
        @AuraEnabled 
        public String tWednesdayClose{get;set;}
        @AuraEnabled 
        public String tWednesdayOpen{get;set;}
        @AuraEnabled 
        public Decimal sZip{get;set;}
        @AuraEnabled 
        public Decimal sZipCode{get;set;}
        @AuraEnabled 
        public String sParkingInstructions{get;set;}
        @AuraEnabled 
        public String tMondayOpen{get;set;}
        @AuraEnabled 
        public String sAddress1{get;set;}
        @AuraEnabled 
        public String sAddress2{get;set;}
        @AuraEnabled 
        public String sCity{get;set;}
        @AuraEnabled 
        public String sCounty{get;set;}
        @AuraEnabled 
        public String sDescription{get;set;}
        @AuraEnabled 
        public String tFridayClose{get;set;}
        @AuraEnabled 
        public String tFridayOpen{get;set;}
        @AuraEnabled 
        public String sLanguage{get;set;}
        @AuraEnabled 
        public String tMondayClose{get;set;}
        @AuraEnabled 
        public String sAccountId{get;set;}
        @AuraEnabled 
        public Boolean bAnnouncementStatus{get;set;}
        @AuraEnabled 
        public String sTimeZone{get;set;}
        @AuraEnabled 
        public Boolean bIsPrimary{get;set;}
        @AuraEnabled 
        public String sDaysLocationClosed{get;set;}
        @AuraEnabled 
        public String sNotes{get;set;}
        @AuraEnabled 
        public String sId{get;set;}
        @AuraEnabled 
        public String email{get;set;}
        @AuraEnabled 
        public String phone{get;set;}
        @AuraEnabled 
        public String url{get;set;}
        public locationWrapper(){}
        
        
        public locationWrapper(Location__c objLocation,Boolean bForTile){
            this.sAddress1 = objLocation.Address1__c;
            this.sAddress2 = objLocation.Address2__c;
            this.sCity = objLocation.City__c;
            this.sState = objLocation.State__c;
            this.sZip = objLocation.Zip__c;
            this.sZipCode = objLocation.Zip__c;
            this.sLocationId = objLocation.Id;
            
        }
        
        public locationWrapper(String AccountId){
            this.sAccountId = AccountId;
           // this.sStatus = 'Active';
             this.sStatus = RE_GlobalConstants.ACTIVE;
            this.bIsPrimary = false;
            this.bAnnouncementStatus = false;
            this.sTimeZone = '';
            this.sLanguage = '';
            this.sDescription = '';
            this.sCounty = '';
            this.sAddress1 = '';
            this.sAddress2 = '';
            this.sDescription = '';
            this.sDaysLocationClosed = '';
            this.sParkingInstructions = '';
        //    this.sZipCode = 0;
            this.sTransportationInstructions = '';
            this.sSpecialLocationInstructions = '';
            this.sSpecialAnnouncements = '';
            this.sPointofContactName = '';
            this.sPointofContactEmail = '';
            this.sPointofContactPhone = '';
            this.sPointofContactPhoneExt = '';
            this.sNotes = '';
            this.sName = '';
           
            this.sState = '';
            this.email = '';
            this.phone = '';
            this.url = '';
            
        }
        
        public locationWrapper(Location__c objLocation){
            this.sAddress1 = objLocation.Address1__c;
            this.sAddress2 = objLocation.Address2__c;
            this.sCity = objLocation.City__c;
            this.sState = objLocation.State__c;
            this.sZipCode = objLocation.Zip__c;
            this.sZip = objLocation.Zip__c;
            this.sLocationId = objLocation.Id;
            this.tMondayOpen = String.valueOf(objLocation.MondayOpen__c);
            this.tMondayClose = String.valueOf(objLocation.MondayClose__c);
            this.tTuesdayOpen = String.valueOf(objLocation.TuesdayOpen__c);
            this.tTuesdayClose = String.valueOf(objLocation.TuesdayClose__c);
            this.tWednesdayOpen = String.valueOf(objLocation.WednesdayOpen__c);
            this.tWednesdayClose = String.valueOf(objLocation.WednesdayClose__c);
            this.tThursdayOpen = String.valueOf(objLocation.ThursdayOpen__c);
            this.tThursdayClose = String.valueOf(objLocation.ThursdayClose__c);
            this.tFridayOpen = String.valueOf(objLocation.FridayOpen__c);
            this.tFridayClose = String.valueOf(objLocation.FridayClose__c);
            this.tSaturdayOpen = String.valueOf(objLocation.SaturdayOpen__c);
            this.tSaturdayClose = String.valueOf(objLocation.SaturdayClose__c);
            this.tSundayOpen = String.valueOf(objLocation.SundayOpen__c);
            this.tSundayClose =String.valueOf(objLocation.SundayClose__c);
            this.sStatus = objLocation.Status__c;
            this.sName = objLocation.Name;
            this.sPointofContactPhone = objLocation.PointofContactPhone__c;
            this.sPointofContactPhoneExt = objLocation.POCPhoneExt__c;
            this.sPointofContactEmail = objLocation.PointofContactEmail__c;
            this.sPointofContactName = objLocation.PointOfContactName__c;
            this.sSpecialAnnouncements = objLocation.SpecialAnnouncements__c;
            this.sSpecialLocationInstructions = objLocation.SpecialLocationInstructions__c;
            this.sTransportationInstructions = objLocation.TransportationInstructions__c;
            this.sParkingInstructions = objLocation.ParkingInstructions__c;
            this.sDescription = objLocation.Description__c;
            this.sLanguage = objLocation.Language__c;
            this.bAnnouncementStatus = objLocation.AnnouncementStatus__c;
            this.sDaysLocationClosed = objLocation.DaysLocationClosed__c;
            this.sId = objLocation.Id;
            this.sTimeZone = objLocation.TimeZone__c;
            this.sNotes = objLocation.Notes__c;
            this.email = objLocation.Email__c;
            this.phone = objLocation.Phone__c;
            this.url = objLocation.LocationWebsite__c;
            
            if(objLocation.LocationType__c == RE_GlobalConstants.sLocationTypeHead)
            {
                this.bIsPrimary = true;
            }
            else{
                this.bIsPrimary = false;
            }
            
        }
        
    }
    
/********************************************************************************************
* @author       Lagan Kankane
* @date         07/24/2019
* @methodname   createLocation
* @description  This methods is used to create a Location record by Community Partner Admin from UI 
* @param        sLocationJson   (String)   : Account record Id
* @return       null 
********************************************************************************************/
    
    @AuraEnabled
    public Static RE_CreateLightningServerResponse createLocation(String strLocationJson){  
        String sLocationJson = String.escapeSingleQuotes(strLocationJson);
        GeneralUtility.isAuthenticatedUser();
        String sResult;
        Boolean bSuccess = false;
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        try {
            if (sLocationJson != null && !String.isBlank(sLocationJson)) {
                locationWrapper retVal = (locationWrapper) JSON.deserialize(sLocationJson, locationWrapper .class);
                
                
                Location__c objLocation = new Location__c();
                objLocation.Account__c = retVal.sAccountId;
                objLocation.Name = retVal.sName;
                objLocation.Address1__c = retVal.sAddress1;
                objLocation.Address2__c = retVal.sAddress2;
                objLocation.City__c = retVal.sCity;
                objLocation.County__c = retVal.sCounty;
                objLocation.DaysLocationClosed__c = retVal.sDaysLocationClosed;
                objLocation.Description__c = retVal.sDescription;
                if(retVal.tMondayClose != null)
                {
                    //Time formattedTime = convertToLocalTime(retVal.tMondayClose);
                    objLocation.MondayClose__c= convertToLocalTime(retVal.tMondayClose); 
                }
                if(retVal.tMondayOpen != null){
                    
                    objLocation.MondayOpen__c = convertToLocalTime(retVal.tMondayOpen);
                }
                objLocation.ParkingInstructions__c = retVal.sParkingInstructions;
                objLocation.SpecialLocationInstructions__c = retVal.sSpecialLocationInstructions;
                objLocation.PointofContactEmail__c = retVal.sPointofContactEmail;
                objLocation.PointOfContactName__c = retVal.sPointofContactName;
                objLocation.PointofContactPhone__c = retVal.sPointofContactPhone;
                objLocation.POCPhoneExt__c = retVal.sPointofContactPhoneExt;
                 if(retVal.tSaturdayClose != null){
                    objLocation.SaturdayClose__c =  convertToLocalTime(retVal.tSaturdayClose);
                 }
                 if(retVal.tSaturdayOpen != null){
                    objLocation.SaturdayOpen__c = convertToLocalTime(retVal.tSaturdayOpen);
                 }
                objLocation.SpecialAnnouncements__c = retVal.sSpecialAnnouncements;
                objLocation.Status__c = retVal.sStatus;
                objLocation.State__c = retVal.sState;
                 if(retVal.tSundayClose != null){
                    objLocation.SundayClose__c = convertToLocalTime(retVal.tSundayClose);
                 }
                 if(retVal.tSundayOpen != null){
                    objLocation.SundayOpen__c = convertToLocalTime(retVal.tSundayOpen);
                 }
                 if(retVal.tThursdayClose != null){
                    objLocation.ThursdayClose__c = convertToLocalTime(retVal.tThursdayClose);
                 }
                 if(retVal.tThursdayOpen != null){
                    objLocation.ThursdayOpen__c = convertToLocalTime(retVal.tThursdayOpen);
                 }
                
                objLocation.TimeZone__c = retVal.sTimeZone;
                objLocation.TransportationInstructions__c = retVal.sTransportationInstructions;
                 if(retVal.tTuesdayClose != null){
                    objLocation.TuesdayClose__c = convertToLocalTime(retVal.tTuesdayClose);
                 }
                 if(retVal.tTuesdayOpen != null){
                    objLocation.TuesdayOpen__c = convertToLocalTime(retVal.tTuesdayOpen);
                 }
                 if(retVal.tWednesdayClose != null){
                    objLocation.WednesdayClose__c = convertToLocalTime(retVal.tWednesdayClose);
                 }
                 if(retVal.tWednesdayOpen != null){
                    objLocation.WednesdayOpen__c = convertToLocalTime(retVal.tWednesdayOpen);
                 }
                objLocation.Zip__c = retVal.sZip;
                 if(retVal.tFridayClose != null){
                    objLocation.FridayClose__c = convertToLocalTime(retVal.tFridayClose);
                 }
                 if(retVal.tFridayOpen != null){
                    objLocation.FridayOpen__c = convertToLocalTime(retVal.tFridayOpen);
                 }
                objLocation.PointofContactPhone__c = retVal.sPointofContactPhone;
               // objLocation.isPrimary__c = retVal.bIsPrimary;
                objLocation.Language__c = retVal.sLanguage;
                objLocation.AnnouncementStatus__c = retVal.bAnnouncementStatus;
                objLocation.Notes__c = retVal.sNotes;
                objLocation.Email__c = retVal.email;
                objLocation.Phone__c =  retVal.phone;
                objLocation.LocationWebsite__c = retVal.url;
                if(retVal.bIsPrimary){
                   // objLocation.LocationType__c = 'Headquarters';
                    objLocation.LocationType__c = RE_GlobalConstants.sLocationTypeHead;
                }
                else {
                    //objLocation.LocationType__c = 'Non Headquarters';
                     objLocation.LocationType__c = RE_GlobalConstants.sLocationTypeNonHead;
                }
                //insert objLocation;
                //
                
                
                
                Database.SaveResult[] InsertedLocation = RE_DataAccessChecker.insertObject(Location__c.getSObjectType(), objLocation);
                bSuccess = true;
                
                
            }
        } catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_LocationCtrl','createLocation',e.getMessage(),true);
            
        }
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    public static Time convertToLocalTime(String inputTime){
        
        
        List<String> lstTimeParams = inputTime.split(':');
        
        Time timeData = Time.newInstance(integer.valueOf(lstTimeParams[0]),integer.valueOf(lstTimeParams[1]),0,0);
      
        return timeData;
        
    }
    
    public class PicklistWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String value {get;set;}
        @AuraEnabled
        public Boolean selected{get;set;}
        
        
        public PicklistWrapper(String label, String value, Boolean selected){
            this.label = label;
            this.value = value; 
            this.selected = selected;
        }
    }
    
}
