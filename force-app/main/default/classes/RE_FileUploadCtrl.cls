/*
* Class Name        : RE_FileUploadCtrl
* Owner             : DELOITTE
* Created Date      : 05/02/2019
* Description       : Controller class for RE_FileUpload Component. 

**/

public with sharing class RE_FileUploadCtrl {
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse saveChunk(Id parentId, String strFileName, String strBase64Data, String strContentType, String strFileId,String strDocType) {
        
        GeneralUtility.isAuthenticatedUser();
        String fileName = String.escapeSingleQuotes(strFileName);
        String base64Data = String.escapeSingleQuotes(strBase64Data);
        String contentType = String.escapeSingleQuotes(strContentType);
        String fileId = String.escapeSingleQuotes(strFileId);
        String sDocType = String.escapeSingleQuotes(strDocType);
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
		Boolean bSuccess = false;
        try{
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            
            fileId = saveFile(parentId, fileName, base64Data, contentType,sDocType);
            }
            else{                
            appendToFile(fileId, base64Data);
        }
            //RE_Release 1.4 – Iron Dome Changes(07/20) - Payal Dubela
            if(String.isNotBlank(fileId))
            {
                mapResponse.put('fileId',fileId);
            	bSuccess = true;
            }            
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_FileUploadCtrl','saveChunk',e.getMessage(), true);
        }        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   saveFile
    * @description  This methods is save the uploaded file to Saleforce File Object
    * @return       Id of the ContentVersion created
    **********************************************************************************************/      
    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType, String sDocType) {        
        GeneralUtility.isAuthenticatedUser();
        String sConVersionId;
        try {
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            List<Schema.SObjectType> objectType = new Schema.SObjectType[] {ContentVersion.SObjectType};
            
            
            ContentVersion objContentVersion = new ContentVersion();
            objContentVersion.ContentLocation = RE_GlobalConstants.CONTENT_LOCATION_SALESFORCE;
            objContentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
            objContentVersion.Title = String.escapeSingleQuotes(fileName);
            objContentVersion.IsMajorVersion = false;
            objContentVersion.PathOnClient = filename ;//+'.' +sExtension;
            
            
            RE_DataAccessChecker.insertSetUpObject(ContentVersion.sObjectType,objContentVersion);
            
            sConVersionId = objContentVersion.id;
            //Shikha: added line to check field accessiblity as per pmd code review comments
            if(RE_DataAccessChecker.isAllowedToAccess(ContentVersion.sObjectType)
               && RE_DataAccessChecker.isSafeField('ContentDocumentId','ContentVersion')){
                   
                   //PMD fixes
                   
                   String sContentDocumentId ='';
                   List<ContentVersion> lstcontentversion;
                   //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
                   if(Schema.sObjectType.ContentVersion.isAccessible() && objContentVersion!=null){
                        lstcontentversion  = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: objContentVersion.Id AND Id != Null];
                   }
                   if(!lstcontentversion.isEmpty()){
                       sContentDocumentId=lstcontentversion[0].ContentDocumentId;
                   }
                   ContentDocumentLink objContentDocLink = new ContentDocumentLink();
                   objContentDocLink.ContentDocumentId = sContentDocumentId;
                   objContentDocLink.LinkedEntityId = String.escapeSingleQuotes(parentId);
                   objContentDocLink.ShareType = RE_GlobalConstants.SHARE_TYPE_VIEWER;
                   objContentDocLink.Visibility = RE_GlobalConstants.VISIBILITY_ALL_USERS;
                   RE_DataAccessChecker.insertObject(ContentDocumentLink.sObjectType,objContentDocLink);
                   
                   //Abhijeet contentdistribution code start
                   ContentDistribution objContentDistribution = new ContentDistribution();
                   objContentDistribution.Name = RE_GlobalConstants.TEST_STRING;
                   objContentDistribution.ContentVersionId = sConVersionId;
                   objContentDistribution.PreferencesAllowViewInBrowser= true;
                   objContentDistribution.PreferencesLinkLatestVersion=true;
                   objContentDistribution.PreferencesNotifyOnVisit=false;
                   objContentDistribution.PreferencesPasswordRequired=false;
                   objContentDistribution.PreferencesAllowOriginalDownload= true;
                   RE_DataAccessChecker.insertSetUpObject(ContentDistribution.sObjectType,objContentDistribution);
                   
                   //Abhijeet contentdistribution code end
                   List<RecordType> REDocumentRecordType;
                   REDocumentRecordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'RE_Documents' AND SobjectType = 'DocumentDetail__c' limit 1];
                   DocumentDetail__c objDocDetail = new DocumentDetail__c(); 
                   objDocDetail.Name = String.escapeSingleQuotes(fileName);
                   objDocDetail.DocumentType__c = String.escapeSingleQuotes(sDocType);
                   objDocDetail.Location__c = parentId;
                   objDocDetail.FileId__c = sContentDocumentId;
                   objDocDetail.RecordTypeId = REDocumentRecordType[0].Id;
                   RE_DataAccessChecker.insertObject(DocumentDetail__c.sObjectType,objDocDetail);
               }
            
            
        } catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 
                                             'RE_FileUploadController',
                                             'saveFile', 
                                             e.getMessage(), 
                                             true);
            return null;
        }
        
        return sConVersionId;
        
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         05/02/2019
    * @methodname   getDocTypesValues
    * @description  This methods is used to get all the Document types values so that End User
    can select the appropiate Doc type from the Upload Modal Box
    * @return       list<String>
    ********************************************************************************************/        
       
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse getDocTypesValues(){
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        //List<String> lstDocumentType = new List<String>();
        Boolean bSuccess = false;
        
        List<Schema.PicklistEntry> lstDocumentTypePicklistOptions = DocumentDetail__c.DocumentType__c.getDescribe().getPicklistValues();
        List<PicklistWrapper> lstDocumentType = new List<PicklistWrapper>();
        for(Schema.PicklistEntry itrStatus : lstDocumentTypePicklistOptions){
            lstDocumentType.add(new PicklistWrapper(itrStatus.getLabel(),itrStatus.getValue(),false));
        } 
		if(!lstDocumentType.isEmpty()){
            mapResponse.put('lstDocumentType', lstDocumentType);
            bSuccess = true;
        }
        /*
        lstDocumentType = GeneralUtility.getPicklistValues('DocumentDetail__c', 'DocumentType__c');
        if(!lstDocumentType.isEmpty()){
            mapResponse.put('lstDocumentType', lstDocumentType);
            bSuccess = true;
        }
        */
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
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
    
    private static void appendToFile(Id fileId, String base64Data) {
        try{
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
       
        
  
        String sFieldsApiName = RE_DataBaseQueryFields.sIdVerContent;
        String sWhereClause = RE_DataBaseQueryFields.sIdinFieldId;
        String sQuery;
        Map<String,String> mapQueryParameters = new Map<String,String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('ContentVersion',sFieldsApiName,mapQueryParameters); 
        
        ContentVersion objCV = new ContentVersion();
        if(RE_DataAccessChecker.isAllowedToAccess(ContentVersion.sObjectType)){
        	 objCV = Database.query(sQuery);
        }
        
 
        String existingBody = EncodingUtil.base64Encode(objCV.VersionData);
 
        objCV.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        
        RE_DataAccessChecker.updateSetUpObject(ContentVersion.sObjectType,objCV); //update objCV;
    }
        catch(Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 
                                             RE_FileUploadCtrl.class.getName() ,
                                             'appendToFile', 
                                             e.getMessage(), 
                                             true);
             
        }
        
    }
    @AuraEnabled
    public static RE_CreateLightningServerResponse getValidExtensions(){
        GeneralUtility.isAuthenticatedUser();
        List<String> validExt=new List<String>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Boolean bSuccess = false;
        for(File_Extension_Setting__c exten : File_Extension_Setting__c.getAll().values()){
            if(exten.Is_Allowed__c){
                validExt.add(exten.Value__c);
            }
        }
        if(!validExt.isEmpty()){
            mapResponse.put('lstValidExt',validExt);
        }
        bSuccess=true;

        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    
}