/*
* classname         : SSP_DocumentCenterCtrl
* @description      : This class is controller for Document Ceter.
* @author           : Aniket Shinde
* @date             : 10/04/2019
* MODIFICATION LOG  :
* DEVELOPER             DATE            DESCRIPTION
* Narapa Pulipati       8/14/2020       Modified for the developement of showing Proper Document Template
                                        when user selects a type of proof and form of proof
* ---------------------------------------------------------------------------------------------
*/ 
public with sharing class SSP_DocumentCenterCtrl {
   
    /**
    * @author: Aniket Shinde
    * @method: saveChunk
    * @desc: Save chunk of file upload from document center
    */
    @AuraEnabled 
    public static SSP_LightningResponse saveChunk(String parentId, String strFileName, String strBase64Data, String strContentType, String strFileId,String strDocType) {
       SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
       SSP_LightningResponse objResponse = new SSP_LightningResponse();
       try{    
            String fileName = String.escapeSingleQuotes(strFileName);
            String base64Data = String.escapeSingleQuotes(strBase64Data);
            String contentType = String.escapeSingleQuotes(strContentType);
            String fileId = String.escapeSingleQuotes(strFileId);
            String sDocType = String.escapeSingleQuotes(strDocType);
            Map<String, Object> mapResponse = new Map<String, Object>();
            Map<String, Object> errorMap = new Map<String, Object>();
            objResponse.bIsSuccess = false;
            if (fileId == '') {
                map<string,id> fileDetailsMap = saveFile(parentId, fileName, base64Data, contentType,sDocType);
                fileId = fileDetailsMap.get('contentVersionId');
                String contentDocId = fileDetailsMap.get('contentDocumentId');
                objResponse.put('contentDocId',contentDocId);
            }
            else{                
                String contentDocId = appendToFile(fileId, base64Data);
                objResponse.put('contentDocId',contentDocId);
            }    
            objResponse.put('fileId',fileId);
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'saveChunk', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }

    /**
    * @author: Aniket Shinde
    * @method: saveFile
    * @desc: Save content data
    */      
    @AuraEnabled
    public static map<string,id> saveFile(String parentId, String fileName, String base64Data, String contentType, String sDocType) {        
        map<string,id> returnMap = new map<string,id>();
        String sConVersionId;
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        List<Schema.SObjectType> objectType = new Schema.SObjectType[] {ContentVersion.SObjectType};
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.VersionData = EncodingUtil.base64Decode(base64Data);
        objContentVersion.Title = String.escapeSingleQuotes(fileName);
        objContentVersion.IsMajorVersion = false;
        objContentVersion.PathOnClient = filename ;
        List<ContentVersion> conVerLst = new List<ContentVersion>{objContentVersion};
        list<String> conVerFieldLst = new list<String>{'VersionData','Title','IsMajorVersion','PathOnClient'};
        conVerLst = (ESAPI.accessController().insertAsUser(conVerLst, conVerFieldLst)).getInsertedObjects();
        sConVersionId = conVerLst[0].id;
        List<ContentVersion> lstRecords =  ((List<ContentVersion>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'ContentVersion'}, new Set<String>{'Id','VersionData','ContentDocumentId'}, new Map<String, String>{'Id'=>sConVersionId}));
        ContentVersion objCV;
        if(lstRecords !=null && !lstRecords.isEmpty())
            objCV = lstRecords[0];
        returnMap.put('contentVersionId',sConVersionId);
        returnMap.put('contentDocumentId',objCV.ContentDocumentId);
        return returnMap;
    }
    
    /**
    * @author: Aniket Shinde
    * @method: appendToFile
    * @desc: append data to content version
    */    
    private static Id appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        List<ContentVersion> lstRecords =  ((List<ContentVersion>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'ContentVersion'}, new Set<String>{'Id','VersionData','ContentDocumentId'}, new Map<String, String>{'Id'=>fileId}));
        ContentVersion objCV;
        if(lstRecords !=null && !lstRecords.isEmpty())
            objCV = lstRecords[0];
        String existingBody = EncodingUtil.base64Encode(objCV.VersionData); 
        objCV.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        List<String> lstConVerFields = new List<String>{'VersionData'};
        ESAPI.accessController().updateAsUser(objCV, lstConVerFields);
        return objCV.ContentDocumentId;
    }
    
    /**
    * @author: Aniket Shinde
    * @method: initDocumentCenter
    * @desc: initiate document center on load
    */
    @AuraEnabled
    public static SSP_LightningResponse initDocumentCenter(){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess = false;
        Boolean hideWizardNavPopup = true;
        try {
            List<User> userLst = SSP_Utility.getCurrentUserDetails();
            String userRole = (SSP_Utility.getUserDetails(userLst[0].Id)).get(SSP_GlobalConstants.USER_ROLE);
            SSP_Utility.SecurityMatrixWrapper accessDetails = SSP_Utility.getScreenAccessDetails('SSP_DocumentCenter',userRole);
            if(accessDetails==null || accessDetails.screenPermission==null){
                accessDetails = new SSP_Utility.SecurityMatrixWrapper();
                accessDetails.canDelete=false;
                accessDetails.fieldPermissions=null;
                accessDetails.screenPermission='NotAccessible';
            }
           
            //Callout
            if(accessDetails.screenPermission!='NotAccessible')
                objResponse.put('rfiInformationPayload',SSP_DocumentHelperService.getRFIInformation(userLst[0], userRole));
            
            // Verify whether first time visit
             String nonCitizenProfile=SSP_Utility.getUserDetails(userLst[0].Id).get('profileName');
            if(userLst[0].contactId!=null && (userRole == SSP_GlobalConstants.CITIZEN_ROLE || 
                                              (nonCitizenProfile==SSP_GlobalConstants.NON_CITIZEN_PROFILE && userLst[0].ImpersonatedIndividualId__c!=null))){
                Contact con = new contact(Id=userLst[0].ContactId,Visited_Document_Center__c=userLst[0].contact.Visited_Document_Center__c);
                hideWizardNavPopup = con.Visited_Document_Center__c;
                objResponse.put('ContactId', con.Id);
                if(!con.Visited_Document_Center__c){
                    con.Visited_Document_Center__c = true;
                    List<String> lstContactFields = new List<String>{'Visited_Document_Center__c'};
                    ESAPI.accessController().updateAsUser(con, lstContactFields);
                }
            }
            objResponse.put('HasUserVisitedDocumentCenter',hideWizardNavPopup);
            objResponse.put('userDocCenterAccess',accessDetails.screenPermission);
            objResponse.bIsSuccess = true; 
            
        } catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'initDocumentCenter', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /**
    * @author: Aniket Shinde
    * @method: getMapContentVerToContentDoc
    * @desc: Get mapping of content version to contente document
    */    
    public static Map<Id,Id> getMapContentVerToContentDoc(List<Id> contentVersionLst){
        Map<Id,Id> contVerToContDocMap = new Map<Id,Id>();
        if(contentVersionLst!=null && contentVersionLst.size()>0)
        {    
            List<ContentVersion> listContVer =  ((List<ContentVersion>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'ContentVersion','operator'=>'AND','IN'=>'Id'}, new Set<String>{'Id','ContentDocumentId'}, new Map<String, String>{'Id'=>String.join(new List<Id>(contentVersionLst), ',')}));
            for(ContentVersion conVer : listContVer)
            {
                contVerToContDocMap.put(conVer.Id,conVer.ContentDocumentId);
            }
        }
        return contVerToContDocMap;
    } 
    
    /**
    * @author: Aniket Shinde
    * @method: wizardProcessUpload
    * @desc: Crate and Link document records for uploaded documents on Document Center Wizard
    */
    @AuraEnabled
    public static SSP_LightningResponse wizardProcessUpload(List<object> docWrapLst, list<Id> contentVersionLst){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess = false;
                
        Map<Id,Id> contVerToContDocMap = SSP_DocumentCenterCtrl.getMapContentVerToContentDoc(contentVersionLst);
        List<User> userLst = SSP_Utility.getCurrentUserDetails();
        Map<String,Object> docDetail;
        List<DocumentDetail__c> docRecList = new List<DocumentDetail__c>();
        ID sspDocTypeRecId = Schema.SObjectType.DocumentDetail__c.getRecordTypeInfosByDeveloperName().get('SSP_Document').getRecordTypeId();
        try {
            for(Object obj : docWrapLst){
                docDetail = new Map<String,Object>();
                docDetail = (Map<String,object>) JSON.deserializeUntyped(JSON.serialize(obj));
                DocumentDetail__c docRec = new DocumentDetail__c();
                docRec.RecordTypeId = sspDocTypeRecId;
                docRec.ContentDocumentId__c = contVerToContDocMap.get((String)docDetail.get('fileId'));
                //docRec.Name = (String)docDetail.get('fileName');
                docRec.Extension__c = (String)docDetail.get('fileType');
                
                
                String strFileName = String.valueof(docDetail.get('fileName'));
                Integer iLimit = strFileName.length() > 80 ? 79 : strFileName.length();
                docRec.Name = strFileName.substring(0,iLimit);
                docRec.Extension__c = (String)docDetail.get('fileType');

                //document details
                docRec.TypeOfDocumentProof__c = (String)docDetail.get('proofCode');
                if(docDetail.get('formOfProof')!=null)
                    docRec.Form_of_Proof__c = (String)docDetail.get('formOfProof');
                if(docDetail.get('caseNumber')!=null)
                    docRec.CaseNumber__c = String.valueOf(docDetail.get('caseNumber'));
                if(docDetail.get('individualId')!=null)
                    docRec.IndividualId__c = String.valueOf(docDetail.get('individualId'));
                if(docDetail.get('description')!=null)
                    docRec.Description__c = (String)docDetail.get('description');
                if(docDetail.get('policyNumber')!=null)
                    docRec.Policy_Number__c = (String)docDetail.get('policyNumber');
                if(docDetail.get('rfiIdentifier')!=null){
                    docRec.UniqueIdentifier__c = (String)docDetail.get('rfiIdentifier');
                }
                // Form of proof name
                if(docDetail.get('proofName')!=null)
                    docRec.Document_Type_Description__c = (String)docDetail.get('proofName');

                //Due Date Logic - Message Center
				if(docDetail.get('sDueDate')!=null){
                    // Format MM DD YYY, ex :  ["09","23","2020"]
                    List<string> dteLst = ((String)docDetail.get('sDueDate')).split('/');
                    //docRec.Due_Date__c = DateTime.newInstance(Integer.valueOf(dteLst[2]), Integer.valueOf(dteLst[1]), Integer.valueOf(dteLst[0]), 00, 00, 00);
                    // Fix for 388475 , format newInstanceGmt(year, month, date, hour, minute, second)
                    docRec.Due_Date__c = DateTime.newInstanceGmt(Integer.valueOf(dteLst[2]), Integer.valueOf(dteLst[0]), Integer.valueOf(dteLst[1]), 00, 00, 00);
                }
                
                //Message Center - Recipient Id population
                String selectedRole = SSP_Utility.getSelectedRole();
                String recipientId = '';
                if( selectedRole==SSP_GlobalConstants.CITIZEN_ROLE ){
                    recipientId = ssp_utility.getIndividualId();
                }
                else{
                    String contactId = (SSP_Utility.getUserDetails(UserInfo.getUserId())).get('contactId');
                    for(AccountContactRelation objACR : [select id, DCContactId__c from AccountContactRelation where 
                                                        DCContactId__c != null AND  Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION 
                                                        AND ContactId = :contactId AND Roles = :selectedRole Limit 1])
                    {
                        Integer intVal = (objACR.DCContactId__c).intValue();
                        recipientId = String.valueOf(Integer.valueOf(intVal));
                    }
                }
                docRec.Notification_Recipient_Id__c = recipientId;             


                //mime type - added by Nupoor
                if((String)docDetail.get('fileType') == 'pdf') {
                    docRec.MimeType__c = 'application/pdf';                    
                }
                else if((String)docDetail.get('fileType') == 'jpg' || (String)docDetail.get('fileType') == 'jpeg') {
                    docRec.MimeType__c = 'image/jpeg';                    
                }
                else if((String)docDetail.get('fileType') == 'tif' || (String)docDetail.get('fileType') == 'tiff') {
                    docRec.MimeType__c = 'image/tiff';                    
                }
                else if((String)docDetail.get('fileType') == 'png') {
                    docRec.MimeType__c = 'image/png';                    
                }
                
                //task code
                if(docDetail.get('taskCode')!=null && docDetail.get('taskCode')!='')
                    docRec.TaskCode__c = (String)docDetail.get('taskCode');
                else if(docDetail.get('isEligibleForRenewal')!=null && 'Y'==(String)docDetail.get('isEligibleForRenewal'))
                    docRec.TaskCode__c = 'RPP';
                else
                    docRec.TaskCode__c = 'VRFP';
                
                
                //other details
                docRec.ReceivedDate__c = SSP_Utility.now();//385801
                docRec.UserId__c = userLst[0].username;
                            
                //add to save list
                docRecList.add(docRec); 
            }
            list<String> lstDocFields = new list<String>{'RecordTypeId',
                'ContentDocumentId__c','Name','Extension__c',
                'TypeOfDocumentProof__c','Form_of_Proof__c','CaseNumber__c','IndividualId__c',
                'Description__c','Policy_Number__c','UniqueIdentifier__c','MimeType__c',
                'TaskCode__c','ReceivedDate__c','UserId__c','Document_Type_Description__c','Due_Date__c','Notification_Recipient_Id__c'};
            docRecList = (ESAPI.accessController().insertAsUser(docRecList, lstDocFields)).getInsertedObjects();

            // Updated for notifications getting expired issue
            // Message Center - Expire notification logic -- start
            Set<String> uniqueRFIIdSet = new Set<String>();
            for(DocumentDetail__c doc : docRecList){
                if(doc.UniqueIdentifier__c != null && doc.UniqueIdentifier__c != '')
                {
                    uniqueRFIIdSet.add(doc.UniqueIdentifier__c);
                }
            }
            if(uniqueRFIIdSet != null && !uniqueRFIIdSet.isEmpty())
            {
                SSP_MessageCenterWithoutSharingService.expireDocCenterNotification(uniqueRFIIdSet);
            }
            // Message Center - Expire notification logic -- end

            List<ContentDocumentLink> cdlLst = new List<ContentDocumentLink>();
            for(DocumentDetail__c curDoc : docRecList) {
                ContentDocumentLink objContentDocLink = new ContentDocumentLink();
                objContentDocLink.ContentDocumentId = curDoc.ContentDocumentId__c;
                objContentDocLink.LinkedEntityId = curDoc.Id;
                objContentDocLink.ShareType = RE_GlobalConstants.SHARE_TYPE_VIEWER;
                objContentDocLink.Visibility = RE_GlobalConstants.VISIBILITY_ALL_USERS;
                cdlLst.add(objContentDocLink);
            }
            list<String> lstFieldsCdlInsert = new list<String>{'ContentDocumentId','LinkedEntityId','ShareType','Visibility'};
            ESAPI.accessController().insertAsUser(cdlLst, lstFieldsCdlInsert);
            
            // Fix for 382061-MY_INFORMATION - start
            Map<String,String> mapUserDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());//Defect 38059 - Keshav
            String primaryIndId = ssp_utility.getIndividualId();
            if(primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE)
            {
                SSP_MessageCenterService.refreshMemberInformation(primaryIndId);
            }
            // Fix for 382061-MY_INFORMATION - end

            objResponse.bIsSuccess = true;
            objResponse.put('DocumentRecords',docRecList);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'wizardProcessUpload', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse; 
    }

     /**
    * @author: Prasanth Prasanth
    * @method: identityWizardProcessUpload
    * @desc: Crate and Link document records for uploaded documents on Document Center Wizard
    */
    @AuraEnabled
    public static SSP_LightningResponse identityWizardProcessUpload(List<object> docWrapLst, list<Id> contentVersionLst){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess = false;
                
        Map<Id,Id> contVerToContDocMap = SSP_DocumentCenterCtrl.getMapContentVerToContentDoc(contentVersionLst);
        List<User> userLst = SSP_Utility.getCurrentUserDetails();
        Map<String,Object> docDetail;
        List<DocumentDetail__c> docRecList = new List<DocumentDetail__c>();
        ID sspDocTypeRecId = Schema.SObjectType.DocumentDetail__c.getRecordTypeInfosByDeveloperName().get('SSP_Document').getRecordTypeId();
        try {
            for(Object obj : docWrapLst){
                docDetail = new Map<String,Object>();
                docDetail = (Map<String,object>) JSON.deserializeUntyped(JSON.serialize(obj));
                DocumentDetail__c docRec = new DocumentDetail__c();
                docRec.RecordTypeId = sspDocTypeRecId;
                docRec.ContentDocumentId__c = contVerToContDocMap.get((String)docDetail.get('fileId'));
                //docRec.Name = (String)docDetail.get('fileName');

                String strFileName = String.valueof(docDetail.get('fileName'));
                Integer iLimit = strFileName.length() > 80 ? 79 : strFileName.length();
                docRec.Name = strFileName.substring(0,iLimit);
                docRec.Extension__c = (String)docDetail.get('fileType');
                
                

                //document details
                docRec.TypeOfDocumentProof__c = (String)docDetail.get('proofCode');
                if(docDetail.get('formOfProof')!=null)
                    docRec.Identity_Form_of_Proof__c = (String)docDetail.get('formOfProof');
                  if(docDetail.get('formOfProof')!=null)
                    docRec.Form_of_Proof__c = (String)docDetail.get('formOfProof');
                if(docDetail.get('caseNumber')!=null)
                    docRec.CaseNumber__c = String.valueOf(docDetail.get('caseNumber'));
                if(docDetail.get('individualId')!=null)
                    docRec.IndividualId__c = String.valueOf(docDetail.get('individualId'));
                if(docDetail.get('description')!=null)
                    docRec.Description__c = (String)docDetail.get('description');
                if(docDetail.get('policyNumber')!=null)
                    docRec.Policy_Number__c = (String)docDetail.get('policyNumber');
                if(docDetail.get('rfiIdentifier')!=null){
                    docRec.UniqueIdentifier__c = (String)docDetail.get('rfiIdentifier');
                }
                // Form of proof name
                if(docDetail.get('proofName')!=null)
                    docRec.Document_Type_Description__c = (String)docDetail.get('proofName');

                //Due Date Logic
				if(docDetail.get('sDueDate')!=null){
                    List<string> dteLst = ((String)docDetail.get('sDueDate')).split('/');
                    docRec.Due_Date__c = DateTime.newInstance(Integer.valueOf(dteLst[2]), Integer.valueOf(dteLst[1]), Integer.valueOf(dteLst[0]), 00, 00, 00);
                    
                }

                //mime type - added by Nupoor
                if((String)docDetail.get('fileType') == 'pdf') {
                    docRec.MimeType__c = 'application/pdf';                    
                }
                else if((String)docDetail.get('fileType') == 'jpg' || (String)docDetail.get('fileType') == 'jpeg') {
                    docRec.MimeType__c = 'image/jpeg';                    
                }
                else if((String)docDetail.get('fileType') == 'tif' || (String)docDetail.get('fileType') == 'tiff') {
                    docRec.MimeType__c = 'image/tiff';                    
                }
                else if((String)docDetail.get('fileType') == 'png') {
                    docRec.MimeType__c = 'image/png';                    
                }
                
                
                
                //other details
                docRec.ReceivedDate__c = SSP_Utility.now();//385801
                docRec.UserId__c = userLst[0].username;
                            
                //add to save list
                docRecList.add(docRec); 
            }
            list<String> lstDocFields = new list<String>{'RecordTypeId',
                'ContentDocumentId__c','Name','Extension__c',
                'TypeOfDocumentProof__c','Identity_Form_of_Proof__c','Form_of_Proof__c','CaseNumber__c','IndividualId__c',
                'Description__c','Policy_Number__c','UniqueIdentifier__c','MimeType__c',
                'TaskCode__c','ReceivedDate__c','UserId__c','Document_Type_Description__c','Due_Date__c'};
            docRecList = (ESAPI.accessController().insertAsUser(docRecList, lstDocFields)).getInsertedObjects();
            
            List<ContentDocumentLink> cdlLst = new List<ContentDocumentLink>();
            for(DocumentDetail__c curDoc : docRecList) {
                ContentDocumentLink objContentDocLink = new ContentDocumentLink();
                objContentDocLink.ContentDocumentId = curDoc.ContentDocumentId__c;
                objContentDocLink.LinkedEntityId = curDoc.Id;
                objContentDocLink.ShareType = RE_GlobalConstants.SHARE_TYPE_VIEWER;
                objContentDocLink.Visibility = RE_GlobalConstants.VISIBILITY_ALL_USERS;
                cdlLst.add(objContentDocLink);
            }
            list<String> lstFieldsCdlInsert = new list<String>{'ContentDocumentId','LinkedEntityId','ShareType','Visibility'};
            ESAPI.accessController().insertAsUser(cdlLst, lstFieldsCdlInsert);
            
            

            objResponse.bIsSuccess = true;
            objResponse.put('DocumentRecords',docRecList);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'wizardProcessUpload', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse; 
    }

      /**
    * @author: Prasanth Prasanth
    * @method: hearingWizardProcessUpload
    * @desc: Crate and Link document records for uploaded documents on Hearing Upload Document
    */
    @AuraEnabled
    public static SSP_LightningResponse hearingWizardProcessUpload(List<object> docWrapLst, list<Id> contentVersionLst){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        String hearingId;
        String hearingRequestId;
        objResponse.bIsSuccess = false;
                
        Map<Id,Id> contVerToContDocMap = SSP_DocumentCenterCtrl.getMapContentVerToContentDoc(contentVersionLst);
        List<User> userLst = SSP_Utility.getCurrentUserDetails();
        Map<String,Object> docDetail;
        List<DocumentDetail__c> docRecList = new List<DocumentDetail__c>();
        ID sspDocTypeRecId = Schema.SObjectType.DocumentDetail__c.getRecordTypeInfosByDeveloperName().get('SSP_Document').getRecordTypeId();
        try {
            for(Object obj : docWrapLst){
                docDetail = new Map<String,Object>();
                docDetail = (Map<String,object>) JSON.deserializeUntyped(JSON.serialize(obj));
                DocumentDetail__c docRec = new DocumentDetail__c();
                docRec.RecordTypeId = sspDocTypeRecId;
                docRec.ContentDocumentId__c = contVerToContDocMap.get((String)docDetail.get('fileId'));
                docRec.Name = (String)docDetail.get('fileName');

                String strFileName = String.valueof(docDetail.get('fileName'));
                Integer iLimit = strFileName.length() > 80 ? 79 : strFileName.length();
                docRec.Name = strFileName.substring(0,iLimit);
                docRec.Extension__c = (String)docDetail.get('fileType');

                docRec.Extension__c = (String)docDetail.get('fileType');
                if(docDetail.get('hearingDocumentType')!=null)
                {
                    docRec.Hearing_Document_Type__c = (String)docDetail.get('hearingDocumentType');
                }
                 if(docDetail.get('hearingRequestNumber')!=null)
                {
                    hearingRequestId=(String)docDetail.get('hearingRequestNumber');
                    docRec.Hearing_Request_Number__c = (String)docDetail.get('hearingRequestNumber');
                }
                if(docDetail.get('hearingDocumentDescription')!=null)
                {
                    docRec.Document_Type_Description__c=(String)docDetail.get('hearingDocumentDescription');
                }
                if(docDetail.get('hearingId')!=null)
                {
                    hearingId=(String)docDetail.get('hearingId');
                    docRec.Hearing_Id__c=(String)docDetail.get('hearingId');
                }
                String selectedRole = SSP_Utility.getSelectedRole();
                String recipientId = '';
                if( selectedRole==SSP_GlobalConstants.CITIZEN_ROLE ){
                    recipientId = ssp_utility.getIndividualId();
                }
                else{
                    String contactId = (SSP_Utility.getUserDetails(UserInfo.getUserId())).get('contactId');
                    for(AccountContactRelation objACR : [select id, DCContactId__c from AccountContactRelation where 
                                                        DCContactId__c != null AND  Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION 
                                                        AND ContactId = :contactId AND Roles = :selectedRole Limit 1])
                    {
                        Integer intVal = (objACR.DCContactId__c).intValue();
                        recipientId = String.valueOf(Integer.valueOf(intVal));
                    }
                }
                docRec.Notification_Recipient_Id__c = recipientId;
                docRec.IndividualId__c=recipientId;//defect 385642
                docRec.ReceivedDate__c = SSP_Utility.now();//385801
                docRec.Due_Date__c=SSP_Utility.today()+30;//defect 385642
                docRec.UserId__c = userLst[0].username;
                if((String)docDetail.get('fileType') == 'pdf') {
                    docRec.MimeType__c = 'application/pdf';                    
                }
                else if((String)docDetail.get('fileType') == 'jpg' || (String)docDetail.get('fileType') == 'jpeg') {
                    docRec.MimeType__c = 'image/jpeg';                    
                }
                else if((String)docDetail.get('fileType') == 'tif' || (String)docDetail.get('fileType') == 'tiff') {
                    docRec.MimeType__c = 'image/tiff';                    
                }
                else if((String)docDetail.get('fileType') == 'png') {
                    docRec.MimeType__c = 'image/png';                    
                }
                //DocumentType__c
                //MimeType__c
                docRecList.add(docRec); 
            }


                list<String> lstDocFields = new list<String>{'RecordTypeId',
                'ContentDocumentId__c','Name','Extension__c',
                'ReceivedDate__c','UserId__c','Document_Type_Description__c','IndividualId__c','Due_Date__c','Hearing_Document_Type__c','Hearing_Request_Number__c','Hearing_Id__c','Notification_Recipient_Id__c','MimeType__c'};
            docRecList = (ESAPI.accessController().insertAsUser(docRecList, lstDocFields)).getInsertedObjects();            
           

            List<ContentDocumentLink> cdlLst = new List<ContentDocumentLink>();
            for(DocumentDetail__c curDoc : docRecList) {
                ContentDocumentLink objContentDocLink = new ContentDocumentLink();
                objContentDocLink.ContentDocumentId = curDoc.ContentDocumentId__c;
                objContentDocLink.LinkedEntityId = curDoc.Id;
                objContentDocLink.ShareType = RE_GlobalConstants.SHARE_TYPE_VIEWER;
                objContentDocLink.Visibility = RE_GlobalConstants.VISIBILITY_ALL_USERS;
                cdlLst.add(objContentDocLink);
            }
            list<String> lstFieldsCdlInsert = new list<String>{'ContentDocumentId','LinkedEntityId','ShareType','Visibility'};
            ESAPI.accessController().insertAsUser(cdlLst, lstFieldsCdlInsert);
            objResponse.bIsSuccess = true;
            objResponse.put('DocumentRecords',docRecList);
            if(string.isNotBlank(hearingId))
            {
              SSP_LightningResponse objResp=SSP_HearingSummaryController.changeNotificationStatus(hearingId,hearingRequestId);
              objResponse.put('NotificationStatus',objResp);
            }
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'hearingWizardProcessUpload', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse; 
    }


    /**
    * @author: Aniket Shinde
    * @method: deleteDocuments
    * @desc: Delete Content Version Documents
    */
    @AuraEnabled
    public static SSP_LightningResponse deleteDocuments(list<Id> contentVersionLst){
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess = false;
        try {
            List<ContentDocument> listDelContDoc = new List<ContentDocument>();
            string temp = String.join(contentVersionLst, ',');
            List<ContentVersion> listContVer =  ((List<ContentVersion>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'ContentVersion','operator'=>'AND','IN'=>'Id'}, new Set<String>{'Id','ContentDocumentId'}, new Map<String, String>{'Id'=>String.join(new List<Id>(contentVersionLst), ',')}));
            for(ContentVersion conVer : listContVer)
            {
                listDelContDoc.add(new ContentDocument(Id = conVer.ContentDocumentId));
            }
            ESAPI.accessController().deleteAsUser(listDelContDoc);
            objResponse.put('DeletedDocuments',listDelContDoc);
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'deleteDocuments', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse; 
    }
    
    /**
     * @description : Wrapper class for RFI Information
     */
    public class RFIInformationWrapper {
        @AuraEnabled public Integer iIndividualId {get;set;}
        @AuraEnabled public Integer iCaseNumber {get;set;}
        @AuraEnabled public String sFullName {get;set;}
        @AuraEnabled public String sTypeOfProof {get;set;}
        @AuraEnabled public String sDueDate {get;set;}
        @AuraEnabled public String sProgramCode {get;set;}
        @AuraEnabled public String sTypeOfProofRefCode {get;set;}
        @AuraEnabled public String sUniqueIdentifier {get;set;}        
        @AuraEnabled public String sRecordIdentifier {get;set;}
        @AuraEnabled public String isEligibleForRenewal {get;set;}
    }
    
    /**
     * @description : Wrapper class for Document Metadata
     */
    public class DocumentMetaDataWrapper {
        @AuraEnabled public Integer iIndividualId {get;set;}
        @AuraEnabled public Integer iCaseNumber{get;set;}
        @AuraEnabled public String sIndividualName {get;set;}
        @AuraEnabled public String sDocumentMetadataId {get;set;}
        @AuraEnabled public String sDocumentName {get;set;}
        @AuraEnabled public String sExtension {get;set;}
        @AuraEnabled public String sMimeType {get;set;}
        @AuraEnabled public String sDocumentType {get;set;}
        @AuraEnabled public String sSubmittedDate {get;set;}
        @AuraEnabled public String sStatuscode {get;set;}
        @AuraEnabled public Boolean isAccepted {get;set;}        
    }
    
    /**
     * @description : Wrapper class All CaseInformation
     */
    public class CaseInformationWrapper {
        @AuraEnabled public List<SSP_DocumentCenterCtrl.individualInfoWrapper> indLst {get;set;}
        @AuraEnabled public Integer caseNumber {get;set;}
    }

    /**
     * @description : Wrapper class All CaseInformation's Individual
     */
    public class individualInfoWrapper {
        @AuraEnabled public Integer value {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String programs {get;set;}
        //Renewal
        @AuraEnabled public String isEligibleForRenewal {get;set;}
    }
    
    /**
    * @author: Aniket Shinde
    * @method: getTypeOfProofs
    * @desc: Fetch type of proofs
    */
    @AuraEnabled 
    public static SSP_LightningResponse getTypeOfProofs() 
    {
        
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess = false;
        try{
            // fetch schema
            Map<String,String> typeOfProofOptionsMap =  SSP_Utility.getPickListValues('SSP_TypeOfProof__mdt', 'TypeOfProof__c', null); 
            list<object> typeOfProofs = new list<object>();
            for(String typeOfProof : typeOfProofOptionsMap.keySet()){
                typeOfProofs.add(new map<string,string>{'value' => typeOfProof, 'label'=>typeOfProofOptionsMap.get(typeOfProof)});
            }
            objResponse.put('typeOfProofs',typeOfProofs);
            objResponse.bIsSuccess = true;
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'getTypeOfProofs', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }

    /**
    * @author: Aniket Shinde
    * @method: getFormOfProofsWizard
    * @desc: Fetch form of proofs for Wizard
    */
    @AuraEnabled  
    public static SSP_LightningResponse getFormOfProofsWizard(String typeOfProofCode) 
    {        
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess = false;
        try{
            list<object> formOfProofs = new list<object>();
            list<object> formOfProofsRecommended = new list<object>();
            Map<String,String> templateTitleMap =  SSP_Utility.getPickListValues('SSP_TypeOfProof__mdt', 'TemplateTitle__c', null); 
            Map<String,Object> proofTemplateMap = new Map<String,Object>() ;
            List<SSP_TypeOfProof__mdt> typeOfProofMdtLst = ((List<ssp_typeofproof__mdt>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'ssp_typeofproof__mdt'}, new Set<String>{'documenttype__c','IsRecommended__c','k_hipp_proof__c','task_code__c','typeofproof__c','TemplateTitle__c','FileName__c'}, new Map<String, String>{'typeofproof__c'=>typeofproofcode}));
            if(!typeOfProofMdtLst.isEmpty() && typeOfProofMdtLst[0].K_Hipp_Proof__c && typeOfProofMdtLst[0].Task_Code__c !=null)
                objResponse.put('taskCode',typeOfProofMdtLst[0].Task_Code__c);
            else
                objResponse.put('taskCode','');
            Map<String,String> formOfProofOptionsMap =  SSP_Utility.getPickListValues('SSP_TypeOfProof__mdt', 'DocumentType__c', null);
            for(SSP_TypeOfProof__mdt typeOfProofRec : typeOfProofMdtLst){
                formOfProofs.add(new map<string,string>{'value' => typeOfProofRec.DocumentType__c, 'label'=>formOfProofOptionsMap.get(typeOfProofRec.DocumentType__c)});
                if(typeOfProofRec.TemplateTitle__c != null && typeOfProofRec.DocumentType__c != null){
                    proofTemplateMap.put(typeOfProofRec.DocumentType__c, new TemplateInfo(typeOfProofRec.TemplateTitle__c,templateTitleMap.get(typeOfProofRec.TemplateTitle__c),typeOfProofRec.FileName__c));
                }
            }
            for(SSP_TypeOfProof__mdt typeOfProofRec : typeOfProofMdtLst){
                if(typeOfProofRec.IsRecommended__c)
                    formOfProofsRecommended.add(new map<string,string>{'value' => typeOfProofRec.DocumentType__c, 'label'=>formOfProofOptionsMap.get(typeOfProofRec.DocumentType__c)});
            }
            objResponse.put('formOfProofs',formOfProofs);
            objResponse.put('formOfProofsRecommended',formOfProofsRecommended);
            objResponse.put('templateMap',proofTemplateMap);

            /**2.5 Security Role Matrix and Program Access. */
            String screenPermission = SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.VERIFICATION_DOCS_POPUP_SCREENID, null).screenPermission;
            objResponse.put(SSP_GlobalConstants.VERIFICATION_DOCS_POPUP, screenPermission != null ? screenPermission : SSP_GlobalConstants.READ_ONLY);
            /** */
            objResponse.bIsSuccess = true;
        }
        catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'getFormOfProofsWizard', ex.getMessage() , true); objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /**
    * @author: Aniket Shinde
    * @method: getFormOfProofs
    * @desc: Fetch form of proofs
    */
    @AuraEnabled 
    public static SSP_LightningResponse getFormOfProofs(String typeOfProofCode) 
    {        
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        objResponse.bIsSuccess = false;
        String userRole;
        Boolean isKHipp = false;
        String taskCode;
        List<SSP_TypeOfProof__mdt> typeOfProofMdtLst;
        list<object> formOfProofs = new list<object>();
        Map<String,String> formOfProofOptionsMap;
        Map<String,String> templateTitleMap =  SSP_Utility.getPickListValues('SSP_TypeOfProof__mdt', 'TemplateTitle__c', null);
        Map<String,Object> proofTemplateMap = new Map<String,Object>() ;
        Set<String> availablePrograms;
        try{
            userRole = (SSP_Utility.getUserDetails(UserInfo.getUserId())).get(SSP_GlobalConstants.USER_ROLE);
            availablePrograms = SSP_Utility.getAvailableProgramsByRole();
            typeOfProofMdtLst =  ((List<ssp_typeofproof__mdt>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'ssp_typeofproof__mdt'}, new Set<String>{'documenttype__c','k_hipp_proof__c','task_code__c','typeofproof__c','TemplateTitle__c','FileName__c'}, new Map<String, String>{'typeofproof__c'=>typeofproofcode}));
            formOfProofOptionsMap =  SSP_Utility.getPickListValues('SSP_TypeOfProof__mdt', 'DocumentType__c', null);
            
            //K-Hipp access considering Role program access And type of proof
            if( (userRole == SSP_GlobalConstants.CITIZEN_ROLE || 
                 (availablePrograms != null && availablePrograms.contains(SSP_GlobalConstants.KP)) )
               && !typeOfProofMdtLst.isEmpty()){
                isKHipp=typeOfProofMdtLst[0].K_Hipp_Proof__c;
            }
            else{
                isKHipp=false;
            }
            
            //Get Task Code for K-Hipp
            if(typeOfProofMdtLst[0].K_Hipp_Proof__c)    
                taskCode = typeOfProofMdtLst[0].Task_Code__c;
            
            //Init select options
            for(SSP_TypeOfProof__mdt typeOfProofRec : typeOfProofMdtLst){
                formOfProofs.add(new map<string,string>{'value' => typeOfProofRec.DocumentType__c, 'label'=>formOfProofOptionsMap.get(typeOfProofRec.DocumentType__c)});
                if(typeOfProofRec.TemplateTitle__c != null && typeOfProofRec.DocumentType__c != null){
                    proofTemplateMap.put(typeOfProofRec.DocumentType__c, new TemplateInfo(typeOfProofRec.TemplateTitle__c,templateTitleMap.get(typeOfProofRec.TemplateTitle__c),typeOfProofRec.FileName__c));
                }
            }
            
            objResponse.put('formOfProofs',formOfProofs);
            objResponse.put('isKHIPTypeOfProof',isKHipp);
            objResponse.put('taskCode',taskCode);
            objResponse.put('templateMap',proofTemplateMap);
            objResponse.bIsSuccess = true;
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'getFormOfProofs', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
    * method        : downloadDocumentMethod
    * @description  : This method is use to get Document base64Data from Service based on DocumentMetaDataId or from Conent Document.
    * @author       : Ashwin Kasture
    * @param        : String sDocumentData - Contains DocumentMetaDataId Or Content Document Id.
    * @return       : SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse downloadDocumentMethod(String sDocumentData) {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            sDocumentData = String.escapeSingleQuotes(sDocumentData);
            Map<String, Object> mapDocumentData = (Map<String, Object>)JSON.deserializeUntyped(sDocumentData);
            String sDocumentMetaDataId = mapDocumentData.get('documentMetaDataId') != null ? (String)mapDocumentData.get('documentMetaDataId') : '';
            String sContentDocumentId = mapDocumentData.get('contentDocumentId') != null ? (String)mapDocumentData.get('contentDocumentId') : '';
            if(String.isNotBlank(sDocumentMetaDataId)) {
                List<Object> lstResponse = SSP_DocumentHelperService.getDmsServiceData(sDocumentMetaDataId);
                String sDmsBase64Data = lstResponse != null && !lstResponse.isEmpty() ? String.valueOf(lstResponse[0]) : 'ERROR Empty Response';                        
                objResponse.put('docBase64Data', sDmsBase64Data);
            } else if(String.isNotBlank(sContentDocumentId)) {
                List<ContentVersion> lstContentVersion = SSP_DocumentHelperService.getContentDocumentData(sContentDocumentId);
                String sContentDocBase64Data = lstContentVersion != null && !lstContentVersion.isEmpty() ? EncodingUtil.base64Encode(lstContentVersion[0].VersionData) : 'ERROR Empty Response';                
                objResponse.put('contentDocBase64Data', sContentDocBase64Data);
            } 
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'downloadDocumentMethod', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }        
        return objResponse;
    }
    
    /*
    * method        : downloadWrittenStatement
    * @description  : This method is use to download Written Statement from static resource.
    * @author       : Nupoor Nimbalkar
    * @param        : 
    * @return       : SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse downloadWrittenStatement() {
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            String staticResourceName;
            if((SSP_Utility.getUserDetails(UserInfo.getUserId())).get('LanguageLocaleKey')=='es_US')
                staticResourceName='DeclarationEscrita';
            else
                staticResourceName='WrittenStatement';
            //PageReference pr = new PageReference('/resource/WrittenStatement');
            PageReference pr = new PageReference('/resource/'+staticResourceName);
        	Blob content;
            if(!test.IsRunningTest()) 
        		content = pr.getContent(); 
        	else
                content = Blob.valueOf('');
            objResponse.put('resourceBody', EncodingUtil.base64Encode(content));
            objResponse.bIsSuccess = true;
        } catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'downloadWrittenStatement', ex.getMessage() , true);  objResponse.bIsSuccess = false; objResponse.addException(ex, lstLogMessages[0].Id);
        }        
        return objResponse;
    }
    
    
    
    /**
    * @author: Aniket Shinde
    * @method: getConfigValues
    * @desc: Get configuration values
    */
    @AuraEnabled 
    public static SSP_LightningResponse getConfigValues() {
       SSP_LightningResponse objResponse = new SSP_LightningResponse();
       map<string,string> responseMap = new map<string,string>();
       try{    
           if(AppConfig__c.getInstance('SSPDocumentCenterCompressionQuality')!=null)
	           objResponse.put('quality',AppConfig__c.getInstance('SSPDocumentCenterCompressionQuality').Value__c);
           if(AppConfig__c.getInstance('SSPDocumentCenterCompressionConvert')!=null)
	           objResponse.put('convertSize',AppConfig__c.getInstance('SSPDocumentCenterCompressionConvert').Value__c);
           objResponse.put('language',UserInfo.getLanguage());
           //Start - Added for Tracker Defect-76
           if(AppConfig__c.getInstance('BenefindPrefix') != null) {
               objResponse.put('benefind',AppConfig__c.getInstance('BenefindPrefix').value__c);
           }
           //End - Added for Tracker Defect-76
            objResponse.bIsSuccess = true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'getConfigValues', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
        /**
    * @author: Prasanth Prasanth
    * @method: getPickListValues
    * @desc: Get PickList Values from Object
    */

    @AuraEnabled
    public static SSP_LightningResponse getPickListValues(String objectName, String fieldName, String firstValue){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse= new SSP_LightningResponse();
        objResponse.bIsSuccess=false;
        try{
             List<User> user=SSP_UserSelector.queryUserData(
                new Map<String, String>{'objectName'=>'User'},
                new Set<String>{'Id','ContactId'},
                new Map<String, String>{'Id'=> UserInfo.getUserId()}
            ); 

            
            if(user!=null && user[0].ContactId<>null)
            {
                  List<Contact> listcon= new List<Contact>() ; 
                listcon = SSP_ContactSelector.queryContactData (
                    new Map<String, String>{'objectName'=>'Contact'},
                    new Set<String>{'Id','Name'},
                    new Map<String, String>{'Id'=> user[0].ContactId}
                );
                
               objResponse.put('loginUserName',listcon[0].Name) ;
            }
            objResponse.put('options',SSP_Utility.getPickListValues(objectName, fieldName, firstValue));
            objResponse.bIsSuccess=true;
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_DocumentCenterCtrl', 'getPickListValues', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
        
    }

     /**
     * TemplateInfo - inner class used to define a data structure to hold file template label,value and url which will be shown to user
     *                 on selection of a Form of Proof and type of Proof
     */
    public class TemplateInfo{

        @AuraEnabled public String value{get;set;}
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String resourceUrl{get;set;}

        public TemplateInfo (String value, String label,String resourceUrl){
            this.value = value;
            this.label = label; 
            this.resourceUrl = resourceUrl;
        }
    }

}