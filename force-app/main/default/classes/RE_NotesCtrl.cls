/**
* Class Name    : RE_NotesCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Controller class for Notes
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  Prashant       Initial Version
*  06/19/2019  Pankaj		  Added getReferralNotes() and moved ContentVersion and ContentNote query to RE_SharingByPassCtrl
*  06/24/2019  Pankaj		  Moved getNotes method to RE_SharingByPassCtrl
**/

public with sharing class RE_NotesCtrl {
    
    /**************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   createNote()
    * @description  This methods is used to create notes
    * @param        String title,string description, String recid
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse createNote(String title, String description, String recid, Boolean isPublic){
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse objResponse;
        try{
            Map<String, String> mapInputs = new Map<String, String>();
		//Fix for Sit error logs
           // mapInputs.put('title', String.escapeSingleQuotes(title));
           //mapInputs.put('title', title != null ?String.escapeSingleQuotes(title):'');
           // mapInputs.put('description', String.escapeSingleQuotes(description));
	       //mapInputs.put('description',description != null ?String.escapeSingleQuotes(description):'');
            if((title != null) || (description != null)) {
                String title1 = String.escapeSingleQuotes(title);
                String notesTitle = title1.replace('\\', '');
                String description1 = String.escapeSingleQuotes(description);
                String notesDescription = description1.replace('\\', '');
                mapInputs.put('title', notesTitle);
                mapInputs.put('description', notesDescription); 
            }
            mapInputs.put('recid', String.escapeSingleQuotes(recid));
            mapInputs.put('isPublic', String.valueOf(isPublic));
            objResponse=RE_SharingByPassCtrl.createNote(mapInputs);
        }
        catch(Exception e){
             LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl', 'createNote', e.getMessage(), true);
        }
        return objResponse;
    }
    
    /**************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   getNotes()
    * @description  This methods is used to get notes to the recid passed
    * @param        String recid,String pageSize, String pageNumber
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getNotes(String recid, String pageSize, String pageNumber) {
       GeneralUtility.isAuthenticatedUser();
       RE_CreateLightningServerResponse objResponse;
        try{
             objResponse=RE_NotesHelper.getNotes(String.escapeSingleQuotes(recid), String.escapeSingleQuotes(pageSize), String.escapeSingleQuotes(pageNumber));
        }
        catch(Exception e){
             LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl', 'getNotes', e.getMessage(), true);
        }
        return objResponse;
    }
    
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   getReferralNotes()
    * @description  This methods is used to get notes to the recid passed
    * @param        String recid,String pageSize, String pageNumber
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getReferralNotes(String recid) {
        GeneralUtility.isAuthenticatedUser();
        String strRecId= (!String.isBlank(recid))?String.escapeSingleQuotes(recid):'';
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        List<NotesWrapper> lstReferralNotes = new List<NotesWrapper>();
        Boolean bSuccess = false;
        //String pageSize = '1000'; 
        //String pageNumber = '1';
        String pageSize = RE_GlobalConstants.pageSize; 
        String pageNumber = RE_GlobalConstants.pageNumber;
        try{
            RE_CreateLightningServerResponse referralNotes  = getNotes(strRecId, pageSize, pageNumber);
            List<NotesWrapper> lstNotesWrapper = (List<NotesWrapper>)JSON.deserialize(''+referralNotes.objectData.get('records'), List<NotesWrapper>.class);
            for(NotesWrapper obj : lstNotesWrapper){
                obj.CreatedDayTime = GeneralUtility.getFormatedDate(String.valueOf(obj.CreatedDate));
                lstReferralNotes.add(obj);
            }
            mapResponse.put('records', lstReferralNotes);
            bSuccess = true;            
        } catch (Exception e) { 
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl', 'getNotes', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         30/07/2019
    * @methodname   checkNoteEditPermission
    * @description  This methods is used to check edit permission for note
    * @param        String  noteid
    * @return       Boolean 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse checkNoteEditPermission(String noteId) {
        GeneralUtility.isAuthenticatedUser();
        Id userId = UserInfo.getuserId();
        Boolean isEditable;
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try {
        String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnClientNotePermission;
        String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnClientNotePermission;
            
        Map<String, String> mapQueryParametersForContentNote = new Map<String, String>();
        mapQueryParametersForContentNote.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapQueryParametersForContentNote.put(RE_GlobalConstants.sLimitKey,'1');
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.noteobjectName, sFieldsApiName, mapQueryParametersForContentNote);
        
        ContentNote contentNote = Database.query(sQuery);
        isEditable=contentNote.CreatedById==userId?true:false;
        mapResponse.put('isEditable',isEditable);
        bSuccess = true;
        }catch(Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl','checkNoteEditPermission', e.getMessage(),true);
        } 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         30/07/2019
    * @methodname   updateNote
    * @description  This methods is used to update notes on edit
    * @param        String noteId String title String description
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateNote(String noteId,String title,String description){
        GeneralUtility.isAuthenticatedUser();
        //SOQL Injection Changes - Payal Dubela - 08/26
        noteId=String.isNotBlank(noteId)?String.escapeSingleQuotes(noteId):noteId;
        title=String.isNotBlank(title)?String.escapeSingleQuotes(title):title;
        description=String.isNotBlank(description)?String.escapeSingleQuotes(description):description;
        String notesTitle = title.replace('\\', '');
        String notesDescription = description.replace('\\', '');
        RE_CreateLightningServerResponse objResponse;
        try{
             //objResponse=RE_SharingByPassCtrl.updateNote(noteId, title, description);
             objResponse=RE_SharingByPassCtrl.updateNote(noteId, notesTitle, notesDescription);
        }
        catch(Exception e){
             LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl', 'updateNote', e.getMessage(), true);
        }
        return objResponse;   
    }
    //Wrapper class to get the notes
    
    public class NotesWrapper {
        @AuraEnabled
        public String NoteId {get;set;}
        @AuraEnabled
        public String Title {get;set;}
        @AuraEnabled       
        public String Description {get;set;}
        @AuraEnabled 
        public String CreatedBy {get;set;}
        @AuraEnabled 
        public Datetime CreatedDate {get;set;}
        @AuraEnabled 
        public Datetime ModifiedDate {get;set;}
        @AuraEnabled 
        public String ModifiedBy {get;set;}
        @AuraEnabled 
        public String CreatedDayTime {get;set;}
        @AuraEnabled
        public Boolean isPublic {get;set;}
        //default constructor
        
        //Create and set two variables label and value as required by the lightning:checkboxGroup
        public NotesWrapper(String NoteId, String Title, String Description, String CreatedBy, Datetime CreatedDate, Datetime ModifiedDate,String ModifiedBy) {
            this.NoteId = noteId;
            this.Title = Title;
            this.Description = Description; 
            this.CreatedBy = CreatedBy; 
            this.CreatedDate = CreatedDate;
            this.ModifiedDate = ModifiedDate;
            this.ModifiedBy = ModifiedBy;
        }
    }
    
}