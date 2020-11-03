/**************************************************************************************
 * @author       Prashant Singh
 * @date         08/05/2019
 * @classname    RE_NotesHelper
 * @description  This is a helper class for Notes Utility
 ******************************************************************************************/
public with sharing class RE_NotesHelper {
	/**************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   getNotes()
    * @description  This methods is used to get notes to the recid passed
    * @param        String recid,String pageSize, String pageNumber
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    public static RE_CreateLightningServerResponse getNotes(String recid, String pageSize, String pageNumber) {
        String recordid = String.escapeSingleQuotes(recid);
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, String> mapResponse = new Map<String, String>();
        Boolean bSuccess = false;
        Integer iPageSize = Integer.valueOf(pageSize);
        Integer iPageNumber = Integer.valueOf(pageNumber) - 1;
        Integer onumber = iPageSize * iPageNumber;
        Blob noteContent;
        String sContentAsString;
        Set<Id> idset = new Set<Id>();
        try {
            String sFieldsApiName = RE_DataBaseQueryFields.sContentDocumentLinkFieldsApiName;
            String sWhereClause = RE_DataBaseQueryFields.sContentDocumentLinkWhereClause;
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            Map<String, String> mapQueryParameters = new Map<String, String>();
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, String.valueOf(iPageSize));
            mapQueryParameters.put(RE_GlobalConstants.sOffset, String.valueOf(onumber));     
            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentDocumentLink', sFieldsApiName, mapQueryParameters);
            List<ContentDocumentLink> lstdocumentlink = RE_SharingByPassCtrl.getContentDocumentLink(sQuery, recordid);
            for (ContentDocumentLink objContentDocLink : lstdocumentlink) {
                idset.add(objContentDocLink.ContentDocumentId);
            }
            List<RE_NotesCtrl.NotesWrapper> lstnotes = new List<RE_NotesCtrl.NotesWrapper>();
            sFieldsApiName = RE_DataBaseQueryFields.sContentDocumentLinkFieldsNames;
            sWhereClause = RE_DataBaseQueryFields.sContentDocumentLinkWhereCondition;
            Map<String, String> mapQueryParametersForContentNote = new Map<String, String>();
            mapQueryParametersForContentNote.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParametersForContentNote.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParametersForContentNote.put(RE_GlobalConstants.sOrderByKey, sOrderby);
            sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentNote', sFieldsApiName, mapQueryParametersForContentNote);
            List<ContentNote> lstContentNotes = Database.query(sQuery);
            Map<String,Boolean> mapCNoteAccess = getNotesPublicOrPrivateFromContentVersion(lstContentNotes);
            for (ContentNote objContentNote : lstContentNotes) {
                noteContent = objContentNote.Content;
                sContentAsString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(noteContent)).toString();                  
                String requiredString = sContentAsString.subString(sContentAsString.indexOf('<p>') + 3, sContentAsString.indexOf('</p>'));
                RE_NotesCtrl.NotesWrapper obj = new RE_NotesCtrl.NotesWrapper(objContentNote.Id,objContentNote.Title, requiredString.unescapeHtml4(), objContentNote.CreatedBy.Name, objContentNote.createddate, objContentNote.LastModifiedDate,objContentNote.LastModifiedBy.Name);
                obj.isPublic = (mapCNoteAccess != null && mapCNoteAccess.containsKey(objContentNote.Id) ? mapCNoteAccess.get(objContentNote.Id) : false);
                lstnotes.add(obj); 
            }
            mapResponse.put('records', JSON.serialize(lstnotes));
            bSuccess = true;            
        } catch (Exception e) { 
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl', 'getNotes', e.getMessage(), true);
            throw e;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);        
    }
    /**************************************************************************************
    * @author       Karthik Gulla
    * @date         08/30/2019
    * @methodname   getNotesPublicOrPrivateFromContentVersion()
    * @description  This methods is used to get Notes details whether they are Public or private
    * @param        List<ContentVersion> lstCVersion
    * @return       Map<Id, Boolean>
    ******************************************************************************************/
    public static Map<String, Boolean> getNotesPublicOrPrivateFromContentVersion(List<ContentNote> lstCNotes){
        Map<String, Boolean> mapVersionPublic = new Map<String,Boolean>();
        Map<Id, Id> mapContentNotesVsVersion = new Map<Id,Id>();
        Set<Id> setVersionIds = new Set<Id>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        String sSwitchCaseKey;
        String sQuery;
        List<ContentVersion> lstCtVersion;
        try{
            for(ContentNote objCNote : lstCNotes){
                setVersionIds.add(objCNote.LatestPublishedVersionId);
                mapContentNotesVsVersion.put(objCNote.LatestPublishedVersionId, objCNote.Id);
            }
            if(!setVersionIds.isEmpty()){
                Map<String,String> mapQueryInputs = new Map<String,String>();
                mapQueryInputs = RE_ResourceCtrl.getQueryDetails(RE_DataBaseQueryFields.sFieldsToQueryOnCV, RE_DataBaseQueryFields.sWhereClauseOnCVForNotes, 'ContentVersion');
                mapQueryInputs.put('setVIds', JSON.serializePretty(setVersionIds));
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, mapQueryInputs.get('whereClause'));
                mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(mapQueryInputs.get('objectName'), mapQueryInputs.get('fieldsApiName'), mapQueryParameters);
                sSwitchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
                switch on (sSwitchCaseKey) {
                    when 'success' {
                        sQuery =  mapResponseData.get(true);
                        lstCtVersion = RE_SharingByPassCtrl.getContentVersions(sQuery,setVersionIds);
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesHelper','getNotesPublicOrPrivateFromContentVersion','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                    }
                }
                for(ContentVersion cVersion:lstCtVersion){
                    mapVersionPublic.put(mapContentNotesVsVersion.get(cVersion.Id), cVersion.isPublic__c);
                }
            }
        }catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','getNotesPublicOrPrivateFromContentVersion', e.getMessage(), true);
        }
        return mapVersionPublic;
    }
}