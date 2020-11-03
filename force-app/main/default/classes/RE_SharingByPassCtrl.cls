/**
* Class Name    : RE_SharingByPassCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : This class contains the operations that needs to by pass the sharing rules
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  27/05/2019  PANKAJ       Initial Version
*  12/23/2019  PANKAJ       Added new method - getResourceTaxonomies()
*  01/07/2020  Megha M      Added new method - getReferralDetails()
*  9/15/2020    Siri           Bug#392883 - RE Security Changes pilot release

**/ 
public without sharing class RE_SharingByPassCtrl {
    
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         05/15/2019
    * @methodname   createUser()
    * @description  This methods is used to create a user record
    * @param        objContact     (Contact)        : contact object
    * @param        sProfileName   (String)         : Profile Name
    * @return       User
    /***********************************************************************************************************/
    public static User insertUser(User objUser, Id profileId){
        try{
            objUser.ProfileId = profileId;
            RE_DataAccessChecker.insertSetUpObject(User.getSObjectType(), objUser);
            RE_UserCreationHelper.assignPermissionSetOnCreate(new Set<Id>{objUser.Id});
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','insertUser',e.getMessage()+' '+e.getStackTraceString(), true);
            throw e;
        }
        return objUser;
    }
    
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         05/15/2019
    * @methodname   updateUserStatusToActive()
    * @description  This methods is used to create a user record
    * @param        User   (sObject) : Contact Id
    * @return       Boolean
    /***********************************************************************************************************/
    public static Boolean updateUserStatusToActive(User objUser){
        Boolean bFlag = false;
        if(objUser != null){
            objUser.isActive = true;
            RE_DataAccessChecker.updateSetUpObject(User.getSObjectType(), objUser);
            bFlag = true;
        }
        return bFlag;
    }
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         05/15/2019
    * @methodname   updateUser()
    * @description  This methods is used to update a user record
    * @param        lstUser     List<User>        : List of User objects to be updated
    * @return       void
    /***********************************************************************************************************/
    public static Boolean updateUser(Map<User, String> mapUserRole, Map<String, Profile> mapProfiles){
        Boolean bIsSuccess = false;
        List<User> lstUserstobeUpdate = new List<User>();
        try{
            Map<String, Map<String, List<String>>> mapRolePermissions = RE_UserCreationHelper.getCommunityUserCofig();
     		for (User objUser : mapUserRole.keySet()) {
                String sProfileName;
                String sUrerRole = mapUserRole.get(objUser); // staff or Admin
                // get the profile name and permission set map
                Map<String, List<String>> mapProfilePermission = mapRolePermissions.get(sUrerRole);
                List<String> setProfileNames = new List<String>(mapProfilePermission.keySet());
                objUser.ProfileId = mapProfiles.get(setProfileNames[0]).Id;
                lstUserstobeUpdate.add(objUser);
            }
            if (lstUserstobeUpdate != null) {
                RE_DataAccessChecker.updateSetUpObjects(User.getSObjectType(), lstUserstobeUpdate);
                Set<Id> setUserIds = new Set<Id>();
                for(User objUser : lstUserstobeUpdate){
                    setUserIds.add(objUser.Id);
                }
                RE_UserCreationHelper.removePermissionSet(setUserIds);
                RE_UserCreationHelper.assignPermissionSet(setUserIds);
                bIsSuccess = true;
            }
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_UserCreationHelper','updateUser',e.getMessage(),false);
            throw e;
        }
        return bIsSuccess;
    }
     /*********************************************************************************************************
    * @author       Srikanth
    * @date         05/29/2019
    * @methodname   fetchOrganizationResults()
    * @description  This methods is used to fetch the account results based on input org name and city
    * @param        organizationName   (String) : organization Name
    * @param        organizationCity   (String) : organization City
    * @return       List<Account> 
    /***********************************************************************************************************/
    public static List<Account> fetchOrganizationResults(String organizationName, String organizationCity){        
        Recordtype objRecordType = GeneralUtility.fetchRecordType(System.Label.AccountRecordType,'Account');
        Id recordTypeId = objRecordType.Id;
        String strOrgname = String.isNotBlank(organizationName)? '\'%'+String.escapeSingleQuotes(organizationName)+'%\'':null;// (organizationName!=null)
        String orgcity = String.isNotBlank(organizationCity)?'%' + String.escapeSingleQuotes(organizationCity) + '%':null;//(organizationCity!=null)
        String orgname = strOrgname;//strOrgname != null ? '%'+strOrgname+'%': null;//[Suresh] - Bug 372966:Claim Site-Organizations with apostrophe in the name is not searchable
        
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        String sAccountInactiveStatus = RE_GlobalConstants.INACTIVE;
        String sAccountWhereClause;
        String sAccountFields = RE_DataBaseQueryFields.sAccountFields;
        if(String.isNotBlank(organizationName)){
            
            if(String.isNotBlank(organizationCity)){
                
                sAccountWhereClause = 'Name LIKE '+orgname +RE_DataBaseQueryFields.sAccountWhereClause;
            }else{
                sAccountWhereClause = 'Name LIKE '+orgname +RE_DataBaseQueryFields.sAccountWhereClauseFilter1;
            }
        }else{
            if(String.isNotBlank(organizationCity)){
                sAccountWhereClause = RE_DataBaseQueryFields.sAccountWhereClauseFilter2;
            }else{
                sAccountWhereClause = RE_DataBaseQueryFields.sAccountWhereClauseFilter3;
            }
        }
        String sAccountSafeQuery;
        Map<String, String> mapAccountQueryParameters = new Map<String, String>();
        mapAccountQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sAccountWhereClause);
        Map<Boolean,String> mapResponseAccount = RE_DataAccessChecker.getFieldsAccessibility('Account',sAccountFields,mapAccountQueryParameters);
        for (Boolean isSuccess : mapResponseAccount.keyset()) {
            if (isSuccess){
                sAccountSafeQuery =  mapResponseAccount.get(isSuccess);
            }
        }
        List<Account> accountResults = (sAccountSafeQuery!= null)? Database.query(sAccountSafeQuery):new List<Account>();
        return accountResults;
    }
    
    
    
    /*********************************************************************************************************
    * @author       Anuj Vashistha
    * @date         06/09/2019
    * @methodname   getAccountOwnerId()
    * @description  This methods is used to fetch the Account owner Id using account id
    * @param        accountId   Id : accountId
    * @return       Id Account.Id
    /***********************************************************************************************************/
    public static Id getAccountOwnerId(Id accountId){
        Id accOwnerId = GeneralUtility.getAccountOwnerId(accountId);
        return accOwnerId;
    }
    
    /*********************************************************************************************************
    * @author       Anuj Vashistha
    * @date         06/09/2019
    * @methodname   getAccountId()
    * @description  This methods is used to get the accountId in a with sharing class(RE_UserCtrl) through a without sharing class
                    and update Account(Organization) as claimed.
    * @param        accountId   Id : accountId
    * @return       Id Account.Id
    ***********************************************************************************************************/
    public static Id getAccountId(Id accountId){
        Id retAccountId;
        String sFieldsToQueryOnAccount = RE_DataBaseQueryFields.sIdNameField;
        String sWhereClauseOnAccount = RE_DataBaseQueryFields.sAccountIdWhereClause;
        Map<String,String> mapAccountQueryParameters = new Map<String,String>();
        mapAccountQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAccount);
        Map<Boolean,String> mapAccountQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Account', sFieldsToQueryOnAccount, mapAccountQueryParameters);
        String switchAccountKey = (mapAccountQueryResponse.get(true) != null) ? 'success' : 'failure';     
        switch on (switchAccountKey) {
            when 'success' {
                String sAccountQuery =  mapAccountQueryResponse.get(true);
                Account objAcc = Database.query(sAccountQuery);
                objAcc.IsClaimed__c = True;
                objAcc.Status__c = 'Active - Allow referrals';
                // for temp solution as Integration not in place.
                RE_DataAccessChecker.updateObject(Account.getSObjectType(), objAcc);
                retAccountId = objAcc.Id;
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','getAccountId','Some Fields doesn\'t have the required access :: '+mapAccountQueryResponse.get(false), true);
            }
        }
        return retAccountId;
    }
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   insertContentDocument()
    * @description  This methods is used to insert Content Document
    * @param        objectType   : sObject Type
    * @param        Sobject : sObject Name
    /***********************************************************************************************************/
    public static Database.SaveResult[] insertContentDocument(Schema.SobjectType objectType, Sobject objContentNote){
        return RE_DataAccessChecker.insertObject(ContentNote.sObjectType,objContentNote);
    }
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   getReferralDetails()
    * @description  This methods is used to fetch referral details
    * @return       List<Referral__c>
    /***********************************************************************************************************/
    public static List<Referral__c> getReferralDetails(Id contactId){
        String sNewStatus = RE_GlobalConstants.STATUS_NEW;
        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', 'ReferralRecord');
        String sFieldsToQueryOnReferral = RE_DataBaseQueryFields.sFieldsToQueryOnReferralObject;
        String sWhereClauseOnReferral = RE_DataBaseQueryFields.sWhereClauseOnReferralObject;
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        List<Referral__c> lstReferral ;
        Map<String,String> mapLocationQueryParameters = new Map<String,String>();
        mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReferral);
        mapLocationQueryParameters.put(RE_GlobalConstants.sOrderByKey, RE_GlobalConstants.sReferralSort);
        mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        Map<Boolean,String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Referral__c', sFieldsToQueryOnReferral, mapLocationQueryParameters);
        
        String switchCaseKey = (mapLocationQueryResponse.get(true) != null) ? 'success' : 'failure'; 
        switch on (switchCaseKey) {
            when 'success' {
                String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Referral__c', RE_DataBaseQueryFields.sFieldsToQueryOnReferralObjectToLabel, mapLocationQueryParameters);
                lstReferral = Database.query(sQuery); 
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserCtrl','getWrapper','Some Fields doesn\'t have the required access :: '+mapLocationQueryResponse.get(false), true);
            }
        }
        return lstReferral;
    }
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/14/2019
    * @methodname   getLocationOperatingHours()
    * @description  This methods is used to get the Location Operating hours
    * @return       Map<String, String>> 
    ******************************************************************************************/
    public static List<Location__c>  getLocationOperatingHours(Set<Id> lstLocations){
        List<Location__c> lstLocation = new List<Location__c>();
        String sFieldsToQueryOnLocation = RE_DataBaseQueryFields.sFieldsToQueryOnLocationObject;
        String sWhereClauseOnLocation = RE_DataBaseQueryFields.sWhereClauseOnLocationObject;
        Map<String,String> mapLocationQueryParameters = new Map<String,String>();
        mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocation);
        Map<Boolean,String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Location__c', sFieldsToQueryOnLocation, mapLocationQueryParameters);
        String switchLocationKey = (mapLocationQueryResponse.get(true) != null) ? 'success' : 'failure';  
        Map<Id,  Map<String, String>> mapLocationOperatingHours = new Map<Id,  Map<String, String>>();
        switch on (switchLocationKey) {
            when 'success' {
                String sLocationQuery =  mapLocationQueryResponse.get(true);
                lstLocation = Database.query(sLocationQuery); 
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingPassCtrl','getLocationOperatingHours','Some Fields doesn\'t have the required access :: '+mapLocationQueryResponse.get(false), true);
            }
        }
        return lstLocation;
    }

    /**************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   createNote()
    * @description  This methods is used to create notes
    * @param        String title,string description, String recid
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    public static RE_CreateLightningServerResponse createNote(Map<String, String> mapInputs){
        String title=mapInputs.get('title');
        String description=mapInputs.get('description');
        String recid=mapInputs.get('recid');
        Boolean isPublic=Boolean.valueOf(mapInputs.get('isPublic'));
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try {            
            ContentNote objContentNote = new ContentNote();
            String body;
            if(description!=null && description!=''){
                body = '<p>' + description + '</p>';
                objContentNote.Content = Blob.valueof(body);
            }
            objContentNote.Title = title;
            Database.SaveResult[] dbSaveResult = RE_SharingByPassCtrl.insertContentDocument(ContentNote.sObjectType,objContentNote);
            
            ContentDocumentLink objContentDocLink = new ContentDocumentLink();
            objContentDocLink.LinkedEntityId = recid;
            objContentDocLink.ContentDocumentId = objContentNote.Id;
            objContentDocLink.ShareType = RE_GlobalConstants.strNotesShareType;
            objContentDocLink.Visibility = RE_GlobalConstants.strNotesVisibility;            
            RE_DataAccessChecker.insertObject(ContentDocumentLink.sObjectType, objContentDocLink);
            bSuccess = true;

            List<ContentVersion> cv=[SELECT isPublic__c, ContentDocumentId, Id FROM ContentVersion where ContentDocumentId=:objContentNote.Id];
            for(ContentVersion c:cv){
                c.isPublic__c=true;
            }
            upsert cv; 
        } catch (Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl', 'createNote', e.getMessage()+' '+e.getStackTraceString(), true);
            throw e;
        }  
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    } 

    /**************************************************************************************
    * @author       Karthik Gulla
    * @date         08/29/2019
    * @methodname   markNotesPublicOrPrivate()
    * @description  This methods is used to mark created notes as Public or Private
    * @param        Database.SaveResult[] lstSaveResults
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    public static void markNotesPublicOrPrivate(Database.SaveResult[] lstSaveResults, Boolean isPublicNote){
        Id contentVersionId = null;
        String sQuery;
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<String, String> mapQueryInputs = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        ContentNote objContentNote = new ContentNote();
        for (Database.SaveResult sr : lstSaveResults) {
            if (sr.isSuccess()) {
                mapQueryInputs = RE_ResourceCtrl.getQueryDetails(RE_DataBaseQueryFields.sFieldsToQueryOnCN, RE_DataBaseQueryFields.sWhereClauseOnCN, 'ContentNote');
                mapQueryInputs.put('contentNoteId', sr.getId());
            }
            else {
                List<String> lstErrors = new List<String>();                
                for(Database.Error err : sr.getErrors()) {
                    lstErrors.add(err.getStatusCode() + ': ' + err.getMessage() + ': '+'markNotesPublicOrPrivate: Error occured during Update of ContentVersion: ' + err.getFields());
                }
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl', 'markNotesPublicOrPrivate', JSON.serializePretty(lstErrors), true);
            }
        }
        if(!mapQueryInputs.isEmpty()){
            List<ContentNote> lstCtNotes = (List<ContentNote>)RE_ResourceCtrl.getQueryResults(mapQueryInputs, null, null);
            if(lstCtNotes!= null && !lstCtNotes.isEmpty()){
                mapQueryInputs.clear();
                mapQueryInputs = RE_ResourceCtrl.getQueryDetails(RE_DataBaseQueryFields.sFieldsToQueryOnCV, RE_DataBaseQueryFields.sWhereClauseOnCV, 'ContentVersion');
                mapQueryInputs.put('contentVersionId', lstCtNotes[0].LatestPublishedVersionId);
                List<ContentVersion> lstCtVersion = (List<ContentVersion>)RE_ResourceCtrl.getQueryResults(mapQueryInputs, null, null);
                lstCtVersion[0].isPublic__c = isPublicNote;
                RE_SharingByPassCtrl.updateSobject(ContentVersion.getSobjectType(),lstCtVersion[0]);
            }
        }
    }

    /**************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   fetchLookUpValues()
    * @description  This methods is used to create notes
    * @param        String searchKeyWord, String ObjectName
    * @return       void 
    ******************************************************************************************/
    public static List < sObject > fetchLookUpValues(Map<String, String> mapInputs) {
        String searchKeyWord=mapInputs.get('searchKeyWord');
        String objectName=mapInputs.get('objectName');
        Id rectypeID=mapInputs.get('rectypeID');
        //RE security changes -Payal
        ID nonCitizenRectypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RE_GlobalConstants.strNonCitizenContactDevName).getRecordTypeId();
        String citizenRole=RE_GlobalConstants.sPercentage+RE_GlobalConstants.strCitizenAppRole+RE_GlobalConstants.sPercentage;
        //Id agencyRectypeID = mapInputs.get('agencyRectypeID'); 
        Boolean bfilter=Boolean.valueOf(mapInputs.get('bfilter'));
        String sQuery;        
        List <sObject> returnList = new List <sObject>();
        List <sObject> lstOfRecords;
        try{
			
            String searchKey = '%' + searchKeyWord + '%';
            String sFieldsApiNameForlstrec;
            String sWhereClauseForlstrec;
            String sAccountStatus = RE_GlobalConstants.sAccountStatus;
            if(objectName=='Account'){
                sFieldsApiNameForlstrec = RE_DataBaseQueryFields.sIdNameField;
                sWhereClauseForlstrec = RE_DataBaseQueryFields.sWhereClauseForlstrec;
            }else if(objectName=='Contact'){
                sFieldsApiNameForlstrec = RE_DataBaseQueryFields.sContactNameFields;
                if(bfilter){
                    sWhereClauseForlstrec = RE_DataBaseQueryFields.sContactNameWhereConditionfilter;
                }else{
                    User u=RE_sharingbypassctrl.getLoggedinUserAccount();
                    Id conAccountId = GeneralUtility.getLoggedInAccountId();   
                    Id conid=u.contactid;
                    String sLoggedInUserRole = GeneralUtility.getLoggedInUserSelectedRole();
                    if(sLoggedInUserRole == RE_GlobalConstants.RE_ASSISTER_ROLE){
                        sWhereClauseForlstrec = RE_DataBaseQueryFields.sContactNameWhereConditionassistor;
                    }else if(sLoggedInUserRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || sLoggedInUserRole == RE_GlobalConstants.CASE_WORKER){ 
                        sWhereClauseForlstrec = RE_DataBaseQueryFields.sContactNameWhereConditionagency;   
                    }
                    else{
                        sWhereClauseForlstrec = RE_DataBaseQueryFields.sContactNameWhereCondition;
                    }
                }
            }else if(objectName=='RE_Taxonomy__c'){
                sFieldsApiNameForlstrec = RE_DataBaseQueryFields.sQueryIdName;
                sWhereClauseForlstrec = RE_DataBaseQueryFields.sWhereClauseTaxonomyLookup;
            }else if(objectName == 'Consent__c'){
                sFieldsApiNameForlstrec = RE_DataBaseQueryFields.sQueryConsentIdName;
                sWhereClauseForlstrec = RE_DataBaseQueryFields.sWhereClauseConsentLookup;
            }  
            else if(objectName == 'Location__c'){
                Id loggedInUserAccountId = GeneralUtility.getLoggedInAccountId();
                sFieldsApiNameForlstrec = RE_DataBaseQueryFields.sQueryIdName;
                sWhereClauseForlstrec = RE_DataBaseQueryFields.sWhereClauseLocationLookup;
            }  
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForlstrec);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '10');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby); 
            
            Map<Boolean,String> mapResponselstrec = RE_DataAccessChecker.getFieldsAccessibility(objectName,sFieldsApiNameForlstrec,mapQueryParameters);
            if(mapResponselstrec.get(true) != null){
                sQuery =  mapResponselstrec.get(true);
                lstOfRecords = Database.query(sQuery);                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_CustomLookupCtrl','fetchLookUpValues','***FLS Violation***'+mapResponselstrec.get(false),true);
            }
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_CustomLookupCtrl','fetchLookUpValues',e.getMessage()+' '+e.getStackTraceString(),true);
        }
        return returnList;
    }
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/18/2019
    * @methodname   getReferralFeedback()
    * @description  This methods is used to get referral feedback records
    * @param        set<Id>     setReferralIds
    * @return       List<Feedback__c> 
    ******************************************************************************************/	
    public static List<Feedback__c> getReferralFeedback(Set<Id> setReferralIds){
        Id feedbackRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Feedback__c', 'PartnerFeedback');
        String sFieldsToQueryOnFeedback = RE_DataBaseQueryFields.sIdReferralId;
        String sWhereClauseOnFeedback = RE_DataBaseQueryFields.sWhereClauseOnFeedback;
        Map<String,String> mapFeedbackQueryParameters = new Map<String,String>();
        mapFeedbackQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnFeedback);
        mapFeedbackQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        List<Feedback__c> lstFeedback = new List<Feedback__c>();
        Map<Boolean,String> mapFeedbackQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Feedback__c', sFieldsToQueryOnFeedback, mapFeedbackQueryParameters);
        String switchFeedbackKey = (mapFeedbackQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchFeedbackKey) {
            when 'success' {
                String sFeedbackQuery = mapFeedbackQueryResponse.get(true);
                lstFeedback = (List<Feedback__c>)Database.query(sFeedbackQuery);
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','getReferralFeedback','Some Fields doesn\'t have the required access :: '+mapFeedbackQueryResponse.get(false), true);
            }
        }
        return lstFeedback;
    }
    
    /********************************************************************************************
    * @author       Akash Sharma
    * @date         14/06/2019
    * @methodname   createFeedback()
    * @description  This methods is used to create the feedback record
    * @param        String accid, String referralId, Integer rating, String Comments
    * @return       void 
    **********************************************************************************************/
    public static List<Feedback__c> getFeedback(String referralId, Id feedbackrecId) {  
        List<Feedback__c> feedbacklst= RE_ReferralDetailsCtrl.getFeedback(referralId,feedbackrecId);
        return feedbacklst;
    }
   /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         09/10/2019
    * @methodname   updateSobject()
    * @description  This methods is used to update sObject without access check
    * @param        Schema.SObjectType, sObject
    * @return       void 
    **********************************************************************************************/
    public static Boolean updateSobject(Schema.SObjectType objType, sObject obj){
        Boolean bFlag = false;
        RE_DataAccessChecker.updateSetUpObject(objType, obj);
        bFlag = true;
        return bFlag;
    }
   /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         09/10/2019
    * @methodname   insertSobject()
    * @description  This methods is used to insert sObject without access check
    * @param        Schema.SObjectType, sObject
    * @return       void 
    **********************************************************************************************/
    public static Boolean insertSobject(Schema.SobjectType objType, Sobject obj){
        Boolean bFlag = false;
        RE_DataAccessChecker.insertSetUpObject(objType, obj);
        bFlag = true;
        return bFlag;
    }
    
      /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         09/10/2019
    * @methodname   insertSobjects()
    * @description  This methods is used to insert sObjects without access check
    * @param        Schema.SObjectType, sObject
    * @return       void 
    **********************************************************************************************/
    public static Boolean insertSobjects(Schema.SobjectType objType, List<SObject> lstObj){
        Boolean bFlag = false;
        RE_DataAccessChecker.insertSetUpObjects(objType, lstObj);
        bFlag = true;
        return bFlag;
    }
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         09/18/2019
    * @methodname   updateSobjects()
    * @description  This methods is used to update sObjects  with out access check
    * @param        Schema.SObjectType, sObject
    * @return       void 
    **********************************************************************************************/
    public static Boolean updateSobjects(Schema.SobjectType objType, List<SObject> lstObj){
        Boolean bFlag = false;
        RE_DataAccessChecker.updateSetUpObjects(objType, lstObj);
        bFlag = true;
        return bFlag;
    }
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         14/06/2019
    * @methodname   fetchLocations()
    * @description  This methods is used to get the locations
    * @param        String accountId
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    public static RE_CreateLightningServerResponse fetchLocations(String accountId){
        String conrecordId = GeneralUtility.getLoggedInUserContactId();
        Map<String, Object> errorMap    = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                Boolean bSuccess = false;  
        String accountrecId = String.escapeSingleQuotes(accountId);
        List<Location__c> lstLocation = new List<Location__c>();
        try{
            String activestatus=RE_GlobalConstants.USER_STATUS_ACTIVE;
            String sFieldsApiNameForlocation = RE_DataBaseQueryFields.sIdNameField;
            String sWhereClauseForlocation = RE_DataBaseQueryFields.sLocationFilter;
            String sQuery;
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForlocation);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby); 
            
            Map<Boolean,String> mapResponselocation = RE_DataAccessChecker.getFieldsAccessibility('Location__c',sFieldsApiNameForlocation,mapQueryParameters);
            if(mapResponselocation.get(true) != null){
                sQuery =  mapResponselocation.get(true);
                lstLocation = Database.query(sQuery);                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_createReferral','fetchLocations','***FLS Violation***'+mapResponselocation.get(false),true);
            }
            mapResponse.put('records', JSON.serialize(lstLocation));
            bSuccess=true;
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateReferral','fetchLocations', e.getMessage()+' '+e.getStackTraceString(), true);
            throw e;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         14/06/2019
    * @methodname   fetchLocationResources()
    * @description  This methods is used to get the Resources
    * @param        String locationId
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    public static RE_CreateLightningServerResponse fetchLocationResources(String locationId){
        List<String> lstRetVal = new List<String>();
        Map<String, Object> errorMap    = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Boolean bSuccess = false;
        try{
            String locationrecId = String.escapeSingleQuotes(locationId);
            List<LocationResource__c> lstLocationResource = new List<LocationResource__c>();
            String activestatus=RE_GlobalConstants.USER_STATUS_ACTIVE;
            String sFieldsApiNameForlocationres = RE_DataBaseQueryFields.sFieldsApiNameForlocationres;
            String sWhereClauseForlocationres = RE_DataBaseQueryFields.sWhereClauseForlocationres;
            String sQuery;
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForlocationres);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '50000');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby); 
            
            Map<Boolean,String> mapResponselocationres = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsApiNameForlocationres,mapQueryParameters);
            if(mapResponselocationres.get(true) != null){
                sQuery =  mapResponselocationres.get(true);
                lstLocationResource = Database.query(sQuery);                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_createReferral','getloggedinuserid','***FLS Violation***'+mapResponselocationres.get(false),true);
            }
            mapResponse.put('records', JSON.serialize(lstLocationResource));
            bSuccess=true;
        }
        catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_CreateReferral','fetchloggedInUserInfo', e.getMessage()+' '+e.getStackTraceString(), true);
            throw e;
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         14/06/2019
    * @methodname   getReferralRecords()
    * @description  This methods is used to get the Referrals
    * @param        RE_CreateReferralCtrl.RE_RefWrapper
    * @return       List<Referral__c>  
    **********************************************************************************************/    
    public static List<Referral__c> getReferralRecords(RE_CreateReferralCtrl.RE_RefWrapper objWrapper){
        String sClosed=RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
        String scontactid=objWrapper.Contact;
        String sresourceid=objWrapper.Resource;
        String saccountid=objWrapper.Organization;
        String sLocationId = objWrapper.Location;
        List<Referral__c> referrallst= new List<Referral__c>();
        String sFieldsApiNameReferral = RE_DataBaseQueryFields.sFieldsApiNameForReferral; 
        String sWhereClauseforReferral=RE_DataBaseQueryFields.sFieldsApiNameForReferralDuplicate;
        String sOrderbyforReferral = RE_DataBaseQueryFields.sCreatedDateASC;
        Map<String,String> mapQueryParametersForReferral = new Map<String,String>();
        mapQueryParametersForReferral.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseforReferral);
        mapQueryParametersForReferral.put(RE_GlobalConstants.sLimitKey, '50000');
        mapQueryParametersForReferral.put(RE_GlobalConstants.sOrderByKey,sOrderbyforReferral);
        Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility('Referral__c',sFieldsApiNameReferral,mapQueryParametersForReferral);

        if(mapResponseReferral.get(true) != null){
            String sQueryForReferral =  mapResponseReferral.get(true);
            referrallst = Database.query(sQueryForReferral);  
        }else{
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','insertReferral','***FLS Violation***'+mapResponseReferral.get(false),true);
        }
        return referrallst;
    }
    
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         06/27/2019
    * @methodname   getCitizenContactDetails()
    * @description  This methods is used to get Citizen contact details
    * @param        Id contactId
    * @return       Contact 
    ******************************************************************************************/
    public static Contact getCitizenContactDetails(Id contactId, String sRole){
         //RE_Release 1.1 – Security Fixes - Payal Dubela(Added Opt out check and changed sobject to list to avoid list has no rows error)
        List<Contact> lstobjContact = new List<Contact>();
        String sFieldsToQueryOnContact = RE_DataBaseQueryFields.sGeoLocationQueryOnContact;
        String sWhereClauseOnContact = RE_GlobalConstants.sEmptyString;
      //  if(sProfileName == RE_GlobalConstants.strCommunityProfileName){
      //  Added By Kojashree -- SSP Merge
        if(sRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN ||sRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF){
            sWhereClauseOnContact = RE_DataBaseQueryFields.sGeoLocationWhereClauseOnContact;
        }else{
            sWhereClauseOnContact = RE_DataBaseQueryFields.sWhereClauseOnContactId;
        }
        Map<String,String> mapContactQueryParameters = new Map<String,String>();
        mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnContact);
        mapContactQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        
        Map<Boolean,String> mapContactQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsToQueryOnContact, mapContactQueryParameters);
        String switchConactKey = (mapContactQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchConactKey) {
            when 'success' {
               /* Map<Id, Double> mapReferralDistance = new Map<Id, Double>();
                Map<Id, String> mapLatLong = new Map<Id, String>();
                Set<Id> lstLocationIds = new Set<Id>();
                Set<Id> setReferralIds = new Set<Id>();*/
                String sContactQuery =  mapContactQueryResponse.get(true);
                //RE_Release 1.1 – Security Fixes - Payal Dubela
                lstobjContact = Database.query(sContactQuery); 
            }
        }
        //RE_Release 1.1 – Security Fixes - Payal Dubela
        return (!lstobjContact.isEmpty() ? lstobjContact[0]:new Contact());
    }
    /**************************************************************************************
    * @author       Prashant
    * @date         06/27/2019
    * @methodname   getContentDocumentLink()
    * @description  This methods is used to get content document link
    * @param        (String sQuery, String recordid)
    * @return       List<ContentDocumentLink> 
    ******************************************************************************************/
    public static List<ContentDocumentLink> getContentDocumentLink(String sQuery, String recordid){
        return Database.query(sQuery);
    }
    
    /**************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   fetchLookUpValues()
    * @description  This methods is used to create notes
    * @param        String recID, String ObjectName
    * @return       void 
    ******************************************************************************************/
    public static sObject getRecord(String recID, String objectName ) {
        List < sObject > returnList = new List < sObject > ();
        sObject sobj;
        try{
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
            String sFieldsApiNameForlstrec = RE_DataBaseQueryFields.sIdNameField;
            String sWhereClauseForlstrec = RE_DataBaseQueryFields.sRecIdCondition;
            String sQuery;
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sOrderby = RE_DataBaseQueryFields.sCreatedDateASC;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForlstrec);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby); 
            
            Map<Boolean,String> mapResponselstrec = RE_DataAccessChecker.getFieldsAccessibility(objectName,sFieldsApiNameForlstrec,mapQueryParameters);
            if(mapResponselstrec.get(true) != null){
                sQuery =  mapResponselstrec.get(true);
                sobj = Database.query(sQuery);                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_CustomLookupCtrl','fetchLookUpValues','***FLS Violation***'+mapResponselstrec.get(false),true);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_CustomLookupCtrl','fetchLookUpValues', e.getMessage()+ ' '+e.getStackTraceString(),true);
            throw e;
        }
        return sobj;
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   getReferralDetails()
    * @description  This methods is used to get the referral record for the record id passed
    * @param        recId           (String)   : record Id
    * @return       RE_CreateLightningServerResponse  
    **********************************************************************************************/
    public static Referral__c getReferralRecords(String sQuery, String recordId){
        return DataBase.query(sQuery);
    }
   /********************************************************************************************
    * @author       Prashant Singh
    * @date         08/05/2019
    * @methodname   getConsentRecords()
    * @description  This methods is used to get the consent records
    * @param        Map<String, String>,            Set<Id> setContactIds
    * @return       List<Object>  
    **********************************************************************************************/
    public static List<Object> getConsentRecords(Map<String, String> mapInputs, Set<Id> setContactIds) {
        String sQuery=mapInputs.get('sQuery');
        Date userInputDate=(mapInputs.get('userInputDate')!=null)?Date.valueOf(mapInputs.get('userInputDate')):null;
        Id contactId=mapInputs.get('contactId');
        //RE Security Changes -- Payal Dubela
        String sAccountId = GeneralUtility.getLoggedInAccountId();
        Date sDate = System.today();
        List<Object> lstConsent = new List<Object>();
        if(sQuery != null){
            lstConsent = Database.query(sQuery);  
        }else{LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCTrl','getConsentRecords','***FLS Violation***',true);}
        return lstConsent;
        
    }
    
    /********************************************************************************************
    * @author       Payal dubela
    * @date         02/07/2019
    * @methodname   getReferralCount()
    * @description  This methods is used to get the referral count for different status
    * @param        clientId           (String)   : contact Id
    * @param        sQuery           (String)   : referrals to query
    * @return       List of Referral 
    **********************************************************************************************/  
    public static List<Referral__c> fetchReferralCount(String sQuery,String clientId){
         return DataBase.query(sQuery);   
    }
    
     /********************************************************************************************
    * @author       Kojashree Kakariya
    * @date         02/07/2019
    * @methodname   getConsentRecordForEmail()
    * @description  Get consent record for Resource Engine Profile
    * @param        sConsentId           (String)   : Consent Id
    * @param        sQuery           (String)   : Consents to query
    * @return       List of Referral 
    **********************************************************************************************/  
    public static List<Consent__c> fetchConsentRecord(String sConsentQuery,String sConsentId){
         return DataBase.query(sConsentQuery);   
    }
   
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocResource()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<LocationResource__c> fetchLocResource(String sLocationResourceQuery, String slocationID, String resourceRecId){
        return Database.query(sLocationResourceQuery);
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
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sResourceQuery;
        String sFieldsApiName;
        String sWhereClause;
        String switchCaseKey;
        String sWhereClauseReferral;
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
            sWhereClauseReferral = 'UserComplete__c = false AND Status__c !=: sClosed';
        }else{
            Id contactId = GeneralUtility.getLoggedInUserContactId(); 
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
        lstResources = Database.query(sResourceQuery); 
        return lstResources;
    }
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocResource()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<Resource__c> fetchResourceData(Map<String, Object> mapInputs){
        Set<String> setResourcesIds = (Set<String>)mapInputs.get('setResourcesIds');
        String sClosed = (String)mapInputs.get('sClosed');
        String sResourceQuery = (String)mapInputs.get('sResourceQuery');
        String sAccountStatus = (String)mapInputs.get('sAccountStatus');
        String contactId = (String)mapInputs.get('contactId');	
        List<Resource__c> resourceList = Database.query(sResourceQuery);
        return resourceList;
    }
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocationsData()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<Location__c> fetchLocationsData(String sLocQuery, Set<String> setLocIds){
        return Database.query(sLocQuery);
    }
    /********************************************************************************************
    * @author       Kojashree Kakariya
    * @date         25/02/2020
    * @methodname   fetchAssesmentResp()
    * @description  This methods is used to get the AssessmentResponse__c Records in RE_SDOH class
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<AssessmentResponse__c> fetchAssesmentResp(String sAssessmentResponseQuery,String userAssessmentTempId,String clientId){
        
        return Database.query(sAssessmentResponseQuery);
    }    
    //Nandita: Added parameter for Assessment Response Record Type
    public static List<AssessmentResponse__c> fetchAssesmentResponseRecords(String sAssessResponseQuery,String sUserAssessId,String sRecTypeAssessUser,Id sAssessmentRespRecTypeId){
        
        return Database.query(sAssessResponseQuery); 
    }
    /********************************************************************************************
    * @author      Kojashree Kakariya
    * @date         10/07/2019
    * @methodname   fetchGoalConfigRecords()
    * @description  This methods is used to get the RE_Config__c Data for Guest User
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<RE_Config__c> fetchGoalConfigRecords(String sConfigQuery, Set<Id> setGoalId, String goalConfigRecId){
        return Database.query(sConfigQuery);
    }
    /********************************************************************************************
    * @author      Kojashree Kakariya
    * @date         10/07/2019
    * @methodname   fetchSDOHDescripCustomSetting()
    * @description  This methods is used to get the RE_Config__c Data for Guest User
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<SDOHDescription__c> fetchSDOHDescripCustomSetting(String sQuery,String sAssessTemplateName, Set<String> setSDOHDmain){
        return Database.query(sQuery);
    }
    /********************************************************************************************
    * @author       Kojashree Kakariya
    * @date         25/02/2020
    * @methodname   fetchSDOHRecords()
    * @description  This methods is used to get the RE_Config__c Data for Guest User
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<SDOH__c> fetchSDOHRecords(String sQuery,String sUserAssessId, Set<String> setSDOHDmain){
        return Database.query(sQuery);
    }
    /********************************************************************************************
    * @author       Kojashree Kakariya
    * @date         25/02/2020
    * @methodname   fetchSDOHRecords()
    * @description  This methods is used to get the RE_Config__c Data for Guest User
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<GoalAnswer__c> fetchGoalAnswerRecords(String sQuery,Set<Id> setAnswerChoiceId){
        return Database.query(sQuery);
    }
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocationsData()
    * @description  This methods is used to get the LocationResource__c Data
    * @param        Resource ID, LocationID           (String)   : contact Id
    * @return       Map<String,Integer>  
    **********************************************************************************************/  
    public static List<LocationResource__c> fetchAllLocationDataOnLR(String sLocationResourceQuery, String sResourceID){
    	return Database.query(sLocationResourceQuery);
    }
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         10/07/2019
    * @methodname   fetchLocationsAddressFields()
    * @description  
    * @param        
    * @return       
    **********************************************************************************************/  
    public static List<Location__c> fetchLocationAddressFields(String sLocationQuery, Set<String> setLocIds){
        return Database.query(sLocationQuery);
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         23/07/2019
    * @methodname   fetchResourceTaxnomies()
    * @description  Fetching resource Taxonomies  
    * @param       
    * @return        List<RE_Resource_Taxonomy__c>
    **********************************************************************************************/  
    public static List<RE_Resource_Taxonomy__c> fetchResourceTaxnomies(String sResourceId){
        String sFieldNamesJunction = RE_DataBaseQueryFields.sQueryFieldsResourceTaxonomy;
        Map<String, String> mapQueryParametersJunctionObj = new Map<String, String>();
        mapQueryParametersJunctionObj.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWhereClauseResourceTaxonomy);
        mapQueryParametersJunctionObj.put(RE_GlobalConstants.sLimitKey, RE_DataBaseQueryFields.sLimit);
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_DataBaseQueryFields.sObjectApiName, sFieldNamesJunction, mapQueryParametersJunctionObj);
        return Database.query(sQuery); 
        
    }
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         23/07/2019
    * @methodname   fetchRelatedTaxnomiesGroup()
    * @description  Fetching resource Taxonomies  
    * @param       
    * @return       List<RE_Config__c> 
    **********************************************************************************************/  
    public static List<RE_Config__c> fetchRelatedTaxnomiesGroup(set<String> setTaxonomyIds){
        Id idSuggestedResourceRecType = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_DataBaseQueryFields.sConfigObjectApiName,'SuggestedResourceMapping');
        String sFieldNames = RE_DataBaseQueryFields.sQueryFieldsRelatedTaxGrp;
        Map<String, String> mapQueryParameters= new Map<String, String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWhereClauseRelatedTaxGrp);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, RE_DataBaseQueryFields.sLimit);
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_DataBaseQueryFields.sConfigObjectApiName, sFieldNames, mapQueryParameters);
        return Database.query(sQuery); 
    }
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         23/07/2019
    * @methodname   fetchTaxnomiesGroupMembers()
    * @description  Fetching resource Taxonomies  
    * @param       
    * @return       List<RE_Config__c>
    **********************************************************************************************/ 
    public static List<RE_Config__c> fetchTaxnomiesGroupMembers(set<String> setTaxonomyGroupIds){
        Id idTaxonomyGrpMemberRecType = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_DataBaseQueryFields.sConfigObjectApiName,'TaxonomyGroupMember'); 
        String sFieldNames = RE_DataBaseQueryFields.sQueryFieldsTaxGrpMembers;
        Map<String, String> mapQueryParameters= new Map<String, String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWhereClauseTaxGrpMembers);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, RE_DataBaseQueryFields.sLimit);
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_DataBaseQueryFields.sConfigObjectApiName, sFieldNames, mapQueryParameters);
        return Database.query(sQuery); 
    }
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         23/07/2019
    * @methodname   fetchFinalResourceTaxnomies()
    * @description  Fetching resource Taxonomies  
    * @param       
    * @return       List<RE_Resource_Taxonomy__c>
    **********************************************************************************************/ 
    public static List<RE_Resource_Taxonomy__c> fetchFinalResourceTaxnomies(set<String> setFinalTaxonomyIds){
        String sFieldNames = RE_DataBaseQueryFields.sQueryFieldsFinalResourceTaxs;
        Map<String, String> mapQueryParameters= new Map<String, String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWhereClauseFinalResourceTaxs);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, RE_DataBaseQueryFields.sLimit);
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_DataBaseQueryFields.sObjectApiName, sFieldNames, mapQueryParameters);
        return Database.query(sQuery); 
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         23/07/2019
    * @methodname   fetchLocationResources()
    * @description    
    * @param       
    * @return       List<LocationResource__c>
    **********************************************************************************************/ 
    public static List<LocationResource__c> fetchLocationResources(set<String> setResourceIds){
        String sFieldNames = RE_DataBaseQueryFields.sQueryFieldsLocResources;
        Map<String, String> mapQueryParameters= new Map<String, String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, RE_DataBaseQueryFields.sWhereClauseLocResources);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, RE_DataBaseQueryFields.sLimit);
        String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_DataBaseQueryFields.sLocResObjectApiName, sFieldNames, mapQueryParameters);
        return Database.query(sQuery); 
        
    }
    
    /********************************************************************************************
    * @author       Suyash Singhal
    * @date         23/07/2019
    * @methodname   insertReferral()
    * @description    
    * @param       
    **********************************************************************************************/ 
    public static void insertReferral(Referral__c objReferral){
        RE_DataAccessChecker.insertObject(Referral__c.getSObjectType(), objReferral);
    }
    
    public static Boolean bIsGuestUser = false;
    public static Boolean bIsResidentUser = false;
    public static Boolean bIsCPUser = false;
    public static Boolean bIsAgencyUser = false; //RE_Release 1.1 - Agency User Capture- Mohan
    /********************************************************************************************
    * @author       Nupoor
    * @date         23/07/2019
    * @methodname   getSearchConfigResults()
    * @description  This method is used to get the search config records
    * @param        Map<String, String> mapInputs
    **********************************************************************************************/
    public static List<RE_Config__c> getSearchConfigResults(Map<String, String> mapInputs){
        String sDomain = mapInputs.get('sDomain');
        String sSubcategory = mapInputs.get('sSubcategory');
        String searchConfigRecId = mapInputs.get('searchConfigRecId');
        List<RE_Config__c> lstSearchConfigResults;
            Map<String,String> mapConfigQueryParameters = new Map<String,String>();
            String sFieldsToQueryOnConfig = RE_DataBaseQueryFields.sFieldsToQueryOnConfigData;
            String sWhereClauseForOnConfig = RE_DataBaseQueryFields.sWhereClauseForOnConfigData;
            String sConfigQuery;
            mapConfigQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForOnConfig);
            Map<Boolean,String> mapResponseConfig = RE_DataAccessChecker.getFieldsAccessibility('RE_Config__c',sFieldsToQueryOnConfig,mapConfigQueryParameters);
            if(mapResponseConfig.get(true) != null){
                sConfigQuery =  mapResponseConfig.get(true);
                lstSearchConfigResults = Database.query(sConfigQuery); 

            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','getCategorySearchResults','***FLS Violation***'+mapResponseConfig.get(false),true);
            } 
        return lstSearchConfigResults;
    }
    /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         07/17/2019
    * @methodname   getLocationResources()
    * @description  This methods is used to get the locaion resources
    * @return       List<LocationResource__c>
    **********************************************************************************************/
    public static List<LocationResource__c> getLocationResources(Map<String, Object> mapInputs){
        Set<Id> setLocationResourceIds = (Set<Id>)mapInputs.get('setLocationResourceIds');
        Set<Id> setGlobalLocaResourceIds;
        if(mapInputs.containsKey('setGlobalLocaResourceIds')){
            setGlobalLocaResourceIds=(Set<Id>)mapInputs.get('setGlobalLocaResourceIds');
        }else{
            setGlobalLocaResourceIds=new Set<Id>();
        }  
        String sAccountStatus = (String)mapInputs.get('sAccountStatus');
        Double dblLat = Double.valueOf(mapInputs.get('dblLat'));
        Double dblLon = Double.valueOf(mapInputs.get('dblLon'));
        String sQuery = (String)mapInputs.get('sQuery');
        String sDomain = (String)mapInputs.get('sDomain');
        Integer iRadiusMiles = Integer.valueOf(System.Label.searchmilesradius); 

        return Database.query(sQuery);
    }
    /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         07/17/2019
    * @methodname   getRferralRecords()
    * @description  This methods is used to get the referral records
    * @return       List<LocationResource__c>
    **********************************************************************************************/
    public static List<Referral__c> getRferralRecords(String sQuery, String contactId, Set<Id> setResourceIds){
        return Database.query(sQuery);
    } 
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getLocationResource()
    * @description  This methods is used to get the Location Resource records
    * @param        List<LocationResource__c> lstLocationResource
    * @return       List<LocationResource__c> 
    **********************************************************************************************/
    public static List<LocationResource__c> getLocationResource(Map<String,String> mapInputs, Set<Id> setResourceId){
       String sLocResQuery= mapInputs.get('sLocResQuery');
       if(mapInputs.containsKey('dblLat') && mapInputs.containsKey('dblLon')){
         Double dblLat=Double.valueOf(mapInputs.get('dblLat'));
        Double dblLon=Double.valueOf(mapInputs.get('dblLon'));
       }
       Integer iRadiusMiles = Integer.valueOf(System.Label.searchmilesradius); 
        return Database.query(sLocResQuery);
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getReferralRecords()
    * @description  This methods is used to get the Referral records
    * @param        List<Referral__c> lstReferals
    * @return       List<Referral__c> 
    **********************************************************************************************/
    public static List<Referral__c> getReferralRecords(String sReferralQuery, Set<Id> setResourceId, Id contactId){
        return Database.query(sReferralQuery);
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   getResourceTaxonomy()
    * @description  This methods is used to get the Resource Taxonomy records
    * @param        List<RE_Resource_Taxonomy__c> lstResourceTaxonomy
    * @return       List<RE_Resource_Taxonomy__c> 
    **********************************************************************************************/
    public static List<RE_Resource_Taxonomy__c> getResourceTaxonomy(String sResTaxonomyQuery, Set<Id> setTaxonomyId, String sAccountStatus){
        return Database.query(sResTaxonomyQuery);
    }
	
    
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         30/07/2019
    * @methodname   updateNote
    * @description  This methods is used to update notes on edit
    * @param        String noteId String title String description
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    public static RE_CreateLightningServerResponse updateNote(String noteId,String title,String description){
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try {            
            ContentNote objContentNote = new ContentNote();
            objContentNote.Id= noteId;
            objContentNote.Title=title;
            String body = RE_GlobalConstants.NOTES_BODY_Tag + description.escapeHtml4()  + RE_GlobalConstants.NOTES_BODY_END_Tag;
            objContentNote.Content = Blob.valueof(body);
            RE_DataAccessChecker.updateSetUpObject(ContentNote.sObjectType,objContentNote);
            bSuccess = true;
        } catch (Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_NotesCtrl', 'updateNote', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
   /* ******************************************************************************************
    * @author       Suyash Singhal
    * @date         16/08/2019
    * @methodname   getFiles- Without Sharing
    * @description  This methods is used to get files without sharing on Resource Details Page
    * @param        Location Record Id
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/    
    public static List<DocumentDetail__c> getFiles(String sQuery, String sParentId){
        return Database.query(sQuery);
    }
   /* ******************************************************************************************
    * @author       Abhijeet Vaishnab
    * @date         16/08/2019
    * @methodname   getContentdistribution()
    * @description  This methods is used to get get the public link for the location attachements/files
    * @param        Map<String,String> mapContentVersionContentId
    * @return       List<Contentdistribution> 
    ******************************************************************************************/  
    public static List<Contentdistribution> getContentdistribution(Map<String,String> mapContentVersionContentId){
        List<Contentdistribution> lstContentDistribution = new List<Contentdistribution>();
        if(Schema.sObjectType.contentdistribution.fields.Id.isAccessible() && Schema.sObjectType.contentdistribution.fields.ContentversionId.isAccessible()
            && Schema.sObjectType.contentdistribution.fields.DistributionPublicUrl.isAccessible()){
        		lstContentDistribution = [SELECT Id,ContentversionId,DistributionPublicUrl FROM contentdistribution where ContentversionId IN: mapContentVersionContentId.keySet()];
            }
		return lstContentDistribution;
    }
   /* ******************************************************************************************
    * @author       Prashant Singh
    * @date         16/08/2019
    * @methodname   getReportConcerRecords()
    * @description  This methods is used to get get the report consern records
    * @param        Map<String,String> mapContentVersionContentId
    * @return       List<Contentdistribution> 
    ******************************************************************************************/ 
    public static ReportConcern__c getReportConcerRecords(String sQuery, String recID){
        return Database.query(sQuery);
    }
    /* ******************************************************************************************
    * @author       Prashant Singh
    * @date         16/08/2019
    * @methodname   getReportConcerRecords()
    * @description  This methods is used to get get the content notes
    * @param        String sQuery, Set<Id> setContentDocumentIds
    * @return       List<ContentNote> 
    ******************************************************************************************/ 
    public static List<ContentNote> getContentNotes(String sQuery, Set<Id> setContentDocumentIds){
        return Database.query(sQuery);
    }
    
    /****************************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/22/2019
    * @methodname   getLocationResources()
    * @description  This methods is used to get the Location Resources.
    * @return       List<LocationResource__c>
    *****************************************************************************************************************/
    public static List<LocationResource__c> getLocationResources(String sQuery, Set<Id> setResourceIds, Set<Id> setLocationIds){
        return Database.query(sQuery);
    }
    /****************************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/22/2019
    * @methodname   createFavorite()
    * @description  This methods is used to create Favorites.
    * @return       RE_CreateLightningServerResponse
    *****************************************************************************************************************/
    public static RE_CreateLightningServerResponse createFavorite(String sLocationResId){
        return RE_CreateFavCtrl.createFavorite(sLocationResId);
    }
    
    /****************************************************************************************************************
    * @author       Srikanth
    * @date         08/27/2019
    * @methodname   createClaimSiteRequest()
    * @description  This methods is used to create Calim Site Request.
    * @return       ClaimMySiteRequest__c
    *****************************************************************************************************************/
    public static ClaimMySiteRequest__c createClaimSite(ClaimMySiteRequest__c claimRecord){
        Database.SaveResult[] sr =  RE_DataAccessChecker.insertObject(ClaimMySiteRequest__c.SObjectType, claimRecord);
        return claimRecord;
    }
     /****************************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/27/2019
    * @methodname   getMyFavorite()
    * @description  This methods is used to create Calim Site Request.
    * @param		Set<Id> setResourceIds, Set<Id> setLocationIds
    * @return       Map<String, Favorite__c>
    *****************************************************************************************************************/
    public static Map<String, Favorite__c> getMyFavorite(Set<Id> setResourceIds, Set<Id> setLocationIds){
        Map<String, Favorite__c> mapFavorites = GeneralUtility.getFavorites(setResourceIds,setLocationIds);
        return mapFavorites;
    }
    /****************************************************************************************************************
    * @author       Ashwin Kasture
    * @date         08/22/2019
    * @methodname   getFavoriteResources()
    * @description  This methods is used to get the Favorites of Resources based on login User & Location Resource.
    * @return       List<Favorite__c>
    *****************************************************************************************************************/
    public static List<Favorite__c> getFavoriteResources(String sQuery, Set<Id> setLocResId, String sContactId,Id sFavRecordTypeId){
        return Database.query(sQuery);
    }
     /****************************************************************************************************************
    * @author       Nandita Bapaye	
    * @date         03/26/2020
    * @methodname   getFavoriteClients()
    * @description  This methods is used to get the Favorites Clients based on logged in User & Client.
    * @return       List<Favorite__c>
    *****************************************************************************************************************/
    
     public static List<Favorite__c> getFavoriteClients(String sQuery, String sClientId, String sContactId,Id sFavRecordTypeId){
        return Database.query(sQuery);
    }
    /********************************************************************************************
    * @author       Nandita Bapaye
    * @date         02/04/2020
    * @methodname   deleteFavoriteClients()
    * @description   function to delete client favorites on optout.
    * @param       
    **********************************************************************************************/ 
    public static void deleteFavoriteClients(List<Favorite__c> LstFav){
        RE_DataAccessChecker.deleteObjects(Favorite__c.sObjectType,lstFav); 
    }
    /*********************************************************************************************************
    * @author       Arun Garg
    * @date         08/28/2019
    * @methodname   getReferralDetails()
    * @description  This methods is used to fetch referral details
    * @return       List<Referral__c>
    /***********************************************************************************************************/
    public static List<Object> getReferralOrganizationDetails(Map<String, String> mapInputs,Set<String> statusSet,Set<Id> resIdset){
        //Map<String, String> mapInputs = new Map<String, String>();

        String sQuery = mapInputs.get('sQuery');
        String sclosed = mapInputs.get('sclosed');
        String sAccId = mapInputs.get('sAccId');
        String conid = mapInputs.get('conid');
        Integer daysopen;
        Date datecreated;
        if(mapInputs.get('daysopen')!=null){
            daysopen = Integer.valueOf(mapInputs.get('daysopen'));
        }
        if(mapInputs.get('datecreated')!=null){
            datecreated = Date.valueOf(mapInputs.get('datecreated'));
        }

        // String sQuery,Set<String> statusSet,String sclosed,String sAccId,String conid,Set<Id> resIdset,Integer daysopen,Date datecreated
        List<Object> lstRecords = new List<Object>();
        lstRecords = Database.query(sQuery);
        return lstRecords;
    }
    /*********************************************************************************************************
    * @author       Suyash Singhal
    * @date         08/28/2019
    * @methodname   getBulkReferralRecords()
    * @description  This methods is used to get the bull referral records
    * @return       List<Referral__c>
    /***********************************************************************************************************/
    public static List<Referral__c> getBulkReferralRecords(Map<String, String> mapInputs, Set<String> setResourceIds){
        String sQuery =  mapInputs.get('sQuery');
        String sContactId = mapInputs.get('sContactId');
        String sClosed = mapInputs.get('sClosed');
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Deeksha Gupta
    * @date         09/03/2019
    * @methodname   getPartnerFeedbackRecords()
    * @description  This methods is used to get partner feedback records
    * @param        
    * @return       List<Feedback__c> 
    ******************************************************************************************/
    public static List<Feedback__c> getPartnerFeedbackRecords(Id accountId, Id locationId, Id resourceId){
        Id feedbackRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Feedback__c', 'PartnerFeedback');
        String sFieldsToQueryOnFeedback = RE_DataBaseQueryFields.sFieldsToQueryOnFeedbackForRating;
        String sWhereClauseOnFeedback ;
        if(locationId!=null){
              sWhereClauseOnFeedback=RE_DataBaseQueryFields.sWhereClauseOnFeedbackForRating; 
        }else{
            sWhereClauseOnFeedback=RE_DataBaseQueryFields.sWhereClauseOnFeedbackForRatingWithoutLocation;
        }
        Map<String,String> mapFeedbackQueryParameters = new Map<String,String>();
        mapFeedbackQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnFeedback);
        List<Feedback__c> lstFeedback = new List<Feedback__c>();
        Map<Boolean,String> mapFeedbackQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Feedback__c', sFieldsToQueryOnFeedback, mapFeedbackQueryParameters);
        String switchFeedbackKey = (mapFeedbackQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchFeedbackKey) {
            when 'success' {
                String sFeedbackQuery = mapFeedbackQueryResponse.get(true);
                lstFeedback = (List<Feedback__c>)Database.query(sFeedbackQuery);
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','getFeedbackRecords','Some Fields doesn\'t have the required access :: '+mapFeedbackQueryResponse.get(false), true);
            }
        }
        return lstFeedback;
    }
    /**************************************************************************************
    * @author       Pankaj M
    * @date         09/03/2019
    * @methodname   getSearchResults()
    * @description  This methods is used to get the search results from Resource, Account, Location & Resource Taxonomy
    * @param        String sKeyWord
    * @return       List<List<sObject>> 
    ******************************************************************************************/
    public static List<List<sObject>> getSearchResults(String sKeyWord){
       // List<List<sObject>> searchList = 
        return [FIND :sKeyword IN ALL FIELDS RETURNING Resource__c(Id, Name,Organization__r.IsClaimed__c,Organization__r.Status__c,SdohDomain__c LIMIT 200), Account(Id,Name,CommonlyUsedName__c,Description,Email__c,Phone,Website LIMIT 200), Location__c(Id,Name,Address1__c,City__c,State__c,Email__c,Phone__c LIMIT 200), RE_Taxonomy__c(Id,Name,Description__c LIMIT 200),LocationResource__c(Id,ResourceDescription__c,Phone__c,Resource__c,Location__c  WHERE Status__c=:RE_GlobalConstants.ACTIVE LIMIT 200)];
    }
    /**************************************************************************************
    * @author       Pankaj M
    * @date         09/03/2019
    * @methodname   getResourceIdsFromAccounts()
    * @description  This methods is used to get resource based on account ids for search functionality
    * @param        Set<Id> setAccountIds
    * @return       Set<Id> 
    ******************************************************************************************/
    public static Set<Id> getResourceIdsFromAccounts(Set<Id> setAccountIds){
        Set<Id> setGlobalSearchResourceIds = new Set<Id>();
        List<Resource__c> lstResource = new List<Resource__c>();
        String sFieldsToQueryOnResource = RE_DataBaseQueryFields.sQueryFieldsOnResource;
        String sWhereClauseOnResource = RE_DataBaseQueryFields.sQueryWhereClauseOnResource;
        Map<String,String> mapResourceQueryParameters = new Map<String,String>();
        mapResourceQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnResource);
        Map<Boolean,String> mapResourceResponse = RE_DataAccessChecker.getFieldsAccessibility('Resource__c', sFieldsToQueryOnResource, mapResourceQueryParameters);
        String switchResourceKey = (mapResourceResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchResourceKey) {
            when 'success' {
                String sQuery = mapResourceResponse.get(true);
                lstResource = Database.query(sQuery);
            }
        }
        for(Resource__c resource : lstResource){
            if(resource.Organization__r.IsClaimed__c == false || (resource.Organization__r.IsClaimed__c == true && resource.Organization__r.Status__c == RE_GlobalConstants.sAccountStatus)){
            setGlobalSearchResourceIds.add(resource.Id);
            } 
        }
        return setGlobalSearchResourceIds;
    }
    
    /**************************************************************************************
    * @author       Sai Velpula
    * @date         09/019/2019
    * @methodname   mostReferralsReferredToOrg()
    * @description  This methods is used to get Count of referrals made by the Current Org to Diff Org's
    * @return       List<AggregateResult> 
    ******************************************************************************************/
    public static List<AggregateResult> mostReferralsReferredToOrg(){
        String loggedInAccountId = GeneralUtility.getLoggedInAccountId();
        List<AggregateResult> mostReferralsReferred = new List<AggregateResult>();
        if (Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && Schema.sObjectType.Referral__c.fields.Name.isAccessible()
        && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() ) {
        mostReferralsReferred= [SELECT ReferredAccountID__r.Name,COUNT(Name) FROM Referral__c where ReferredByAccountID__c=:loggedInAccountId and (DateOfReferral__c=LAst_N_Months:6 or DateOfReferral__c =THIS_Month) Group By ReferredAccountID__r.Name Order By Count(Name) Desc Limit 5];
        }
        return mostReferralsReferred;
    }
    
    /* offset method for Search Query */
    /*public static Set<Id> getSearchResults(String sKeyword, Map<String, Integer> mapPagePrams){
        Integer iPageSize = mapPagePrams.get('iPageSize');
        Integer iPageNumber = mapPagePrams.get('pageNumber') - 1;
        Integer iOffset = mapPagePrams.get('iPageSize') * iPageNumber;        
        //List<List<SObject>> lstResources = [FIND :sKeyword IN ALL FIELDS RETURNING Resource__c(Id, Name, Description__c LIMIT :iPageSize OFFSET :iOffset)];
        List<List<SObject>> lstResources = [FIND :sKeyword IN ALL FIELDS RETURNING Resource__c(Id, Name, Description__c ) LIMIT 100];

        //List<List<SObject>> lstAccounts = [FIND :sKeyword IN ALL FIELDS RETURNING Account(Id,Name,CommonlyUsedName__c,Description,Email__c,Phone,Website LIMIT :iPageSize OFFSET :iOffset)];
        List<List<SObject>> lstAccounts = [FIND :sKeyword IN ALL FIELDS RETURNING Account(Id,Name,CommonlyUsedName__c,Description,Email__c,Phone,Website)  LIMIT 100];

        //List<List<SObject>> lstLocations = [FIND :sKeyword IN ALL FIELDS RETURNING Location__c(Id,Name,Address1__c,City__c,State__c,Email__c,Phone__c LIMIT :iPageSize OFFSET :iOffset)];
        List<List<SObject>> lstLocations = [FIND :sKeyword IN ALL FIELDS RETURNING Location__c(Id,Name,Address1__c,City__c,State__c,Email__c,Phone__c)  LIMIT 100];

        //List<List<SObject>> lstTaxonomys = [FIND :sKeyword IN ALL FIELDS RETURNING RE_Taxonomy__c(Id,Name,Description__c LIMIT :iPageSize OFFSET :iOffset)];
        List<List<SObject>> lstTaxonomys = [FIND :sKeyword IN ALL FIELDS RETURNING RE_Taxonomy__c(Id,Name,Description__c)  LIMIT 100];

        Set<Id> setResourceIds = new Set<Id>();
        // get the resource Ids from resource record having the match
        for(Resource__c objResource : (List<Resource__c>)lstResources[0]){
           // if((objResource.Name != null && objResource.Name.containsIgnoreCase(sKeyword)) || (objResource.Description__c != null && objResource.Description__c.containsIgnoreCase(sKeyword))){
                setResourceIds.add(objResource.Id);
          //  }
        }
        Set<Id> setAccountIds= new Set<Id>();
        // get the resource Ids from resource record having the match
        for(Account obj : (List<Account>)lstAccounts[0]){
            
           // if(obj.Name.containsIgnoreCase(sKeyword) ||(obj.CommonlyUsedName__c != null && obj.CommonlyUsedName__c.containsIgnoreCase(sKeyword)) ||
             //  (obj.Description != null && obj.Description.containsIgnoreCase(sKeyword)) || (obj.Email__c != null && obj.Email__c.containsIgnoreCase(sKeyword)) ||
             //  (obj.Phone != null && obj.Phone.containsIgnoreCase(sKeyword)) || (obj.Website != null && obj.Website.containsIgnoreCase(sKeyword))){
                   setAccountIds.add(obj.Id);
             //  }
        }
        if(RE_SharingByPassCtrl.getResourceIdsFromAccounts(setAccountIds) != null){
            setResourceIds.addAll(RE_SharingByPassCtrl.getResourceIdsFromAccounts(setAccountIds));
        }
        Set<Id> setLocationIds= new Set<Id>();
        // get the resource Ids from Location record having the match
        for(Location__c obj : (List<Location__c>)lstLocations[0]){
            // setResourceIds.add(objLocation.Id);
           // if(obj.Name.containsIgnoreCase(sKeyword) || (obj.Address1__c != null && obj.Address1__c.containsIgnoreCase(sKeyword)) ||
               //(obj.City__c != null && obj.City__c.containsIgnoreCase(sKeyword)) || (obj.State__c != null && obj.State__c.containsIgnoreCase(sKeyword)) ||
               //(obj.Email__c != null && obj.Email__c.containsIgnoreCase(sKeyword)) || (obj.Phone__c != null && obj.Phone__c.containsIgnoreCase(sKeyword))){
                   setLocationIds.add(obj.Id); 
              // }
        }
        if(RE_BasicSearchHelper.getResourceIdsFromResourceLocation(setLocationIds) != null){
            setResourceIds.addAll(RE_BasicSearchHelper.getResourceIdsFromResourceLocation(setLocationIds));
        }
        Set<Id> setTaxonomyIds = new Set<Id>();
        // get the resource Ids from Taxonomy record having the match
        for(RE_Taxonomy__c obj : (List<RE_Taxonomy__c>)lstTaxonomys[0]){
          //  if((obj.Name != null && obj.Name.containsIgnoreCase(sKeyword)) || (obj.Description__c != null && obj.Description__c.containsIgnoreCase(sKeyword))){
                setTaxonomyIds.add(obj.Id); 
          //  }
        }
        if(RE_BasicSearchHelper.getResourceTaxonomiesIds(setTaxonomyIds) != null){
            setResourceIds.addAll(RE_BasicSearchHelper.getResourceTaxonomiesIds(setTaxonomyIds));  
        }
        return setResourceIds;
    }*/
    
   /* public static List<LocationResource__c> getLocationResources(Set<Id> setLocationResourceIds, Map<String, String> mapInputs){
        String sDomain = mapInputs.get('sDomain');
        Double dblLat = Double.valueOf(mapInputs.get('dblLat'));
        Double dblLon = Double.valueOf(mapInputs.get('dblLon'));

        List<LocationResource__c> lstLocationResources;
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        Map<String,String> mapLocResourceQueryParameters = new Map<String,String>();
        String sWhereClauseForLocResource = RE_GlobalConstants.sEmptyString;
        Map<Boolean,String> mapLocResourceResponse = new Map<Boolean,String>();
        String sOrderby = RE_DataBaseQueryFields.sOrderByClauseOnLocRes;
        String sLocResourceQuery;
        String sFieldsToQueryOnLocResource = RE_DataBaseQueryFields.sFieldsToQueryOnLocResource;
        if(sDomain == null){
            sWhereClauseForLocResource = RE_DataBaseQueryFields.sWhereClauseForLocResourceNoDomain;
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForLocResource);
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            mapLocResourceResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsToQueryOnLocResource,mapLocResourceQueryParameters);
            if(mapLocResourceResponse.get(true) != null){
                sLocResourceQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('LocationResource__c', RE_DataBaseQueryFields.sFieldsToQueryOnLocResourceToLabel,mapLocResourceQueryParameters);                
                Map<String, Object> mapDataInputs = new Map<String, Object>();
                mapDataInputs.put('setLocationResourceIds',setLocationResourceIds);
                mapDataInputs.put('sAccountStatus',sAccountStatus);
                mapDataInputs.put('dblLat',dblLat);
                mapDataInputs.put('dblLon',dblLon);
                mapDataInputs.put('sQuery',sLocResourceQuery);

                lstLocationResources = RE_SharingByPassCtrl.getLocationResources(mapDataInputs);  

            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','getCategorySearchResults','***FLS Violation***'+mapLocResourceResponse.get(false),true);
            } 
        }else{
            sWhereClauseForLocResource = RE_DataBaseQueryFields.sWhereClauseForLocResourceWithDomain;
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForLocResource);
            mapLocResourceQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
            mapLocResourceResponse = RE_DataAccessChecker.getFieldsAccessibility('LocationResource__c',sFieldsToQueryOnLocResource,mapLocResourceQueryParameters);
            if(mapLocResourceResponse.get(true) != null){
                sLocResourceQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('LocationResource__c', RE_DataBaseQueryFields.sFieldsToQueryOnLocResourceToLabel,mapLocResourceQueryParameters);                
                Map<String, Object> mapDataInputs = new Map<String, Object>();
                mapDataInputs.put('setLocationResourceIds',setLocationResourceIds);
                mapDataInputs.put('sAccountStatus',sAccountStatus);
                mapDataInputs.put('dblLat',dblLat);
                mapDataInputs.put('dblLon',dblLon);
                mapDataInputs.put('sQuery',sLocResourceQuery);
                mapDataInputs.put('sDomain',sDomain);
                lstLocationResources = RE_SharingByPassCtrl.getLocationResources(mapDataInputs);

            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','getLocationResources','***FLS Violation***'+mapLocResourceResponse.get(false),true);
            } 
        }
        return lstLocationResources;
    }*///

    /********************************************************************************************
    * @author       Payal Dubela
    * @date         10/04/2019
    * @methodname   fetchLocResource()
    * @description  This methods is used to get the Resource Data(new for search optimization)
    * @param        set of ids  
    * @return       Map<Resource__c>  
    **********************************************************************************************/  
    public static List<Resource__c> fetchResourceDataSearch(Set<String> setResourcesIds){
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sResourceQuery;
        String sFieldsApiName;
        String sWhereClause;
        String switchCaseKey;
        String sWhereClauseReferral;
        List<Resource__c> lstResources;
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        sFieldsApiName = RE_DataBaseQueryFields.sFieldsForResourceSearch;
        sWhereClause = RE_DataBaseQueryFields.sWhereClauseResourceRDResidentViewCtrl;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        sResourceQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('Resource__c',sFieldsApiName, mapQueryParameters);
        String sRelationshipName;
        for(ChildRelationship rel: Resource__c.SObjectType.getDescribe().getChildRelationships()) {
            if(rel.getChildSObject() == Referral__c.SObjectType) {
                sRelationshipName = rel.getRelationshipName();
                break;
            } 
        }
        if (UserInfo.getUserType() == 'Guest') {
             sWhereClauseReferral = 'UserComplete__c = false AND Status__c IN: referralstatus';
        }else{
            Id contactId = GeneralUtility.getLoggedInUserContactId(); 
            sWhereClauseReferral = RE_DataBaseQueryFields.sWhereClauseReferralRDResidentViewCtrlKeywordSearch;
        }
        String sChildReferralQuery;
        String sFieldsApiNameReferral = RE_DataBaseQueryFields.sQueryReferralFieldsRDResidentViewCtrl;
        String sClosed = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
        List<String> referralstatus = new List<String>{RE_GlobalConstants.STATUS_NEW,RE_GlobalConstants.STATUS_INPROGRESS_ORG_IN_SYSTEM,RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM,RE_GlobalConstants.REFERRAL_STATUS_DRAFT};
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
        lstResources = Database.query(sResourceQuery); 
        return lstResources;
    }

    /**************************************************************************************
    * @author       Payal Dubela
    * @date         10/15/2019
    * @methodname   getContentDocumentLinks()
    * @description  This methods is used to get content document links for related records
    * @param        (String sQuery,Map<String,>)
    * @return       List<ContentDocumentLink> 
    ******************************************************************************************/
    public static List<ContentDocumentLink> getContentDocumentLinks(String sQuery, Set<Id> setReferralIds){
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         10/15/2019
    * @methodname   getContentVersions()
    * @description  This methods is used to get content versions for related records
    * @param        (String sQuery,Set<Id>)
    * @return       List<Contentversion> 
    ******************************************************************************************/
    public static List<ContentVersion> getContentVersions(String sQuery, Set<Id> setVersionIds){
        return Database.query(sQuery);
    }
	/**************************************************************************************
    * @author       Megha Mittal
    * @date         10/23/2019
    * @methodname   getSurveyRecords()
    * @description  This methods is used to fetch Survey
    * @param        (String)
    * @return       Survey 
    ******************************************************************************************/
    public static Survey getSurveyRecords(String SurveyName){
        String sFieldsToQueryOnSurvey = RE_DataBaseQueryFields.sFieldsToQueryOnSurvey;
        String sWhereClauseOnSurvey = RE_DataBaseQueryFields.sWhereClauseOnSurvey;
        Map<String,String> mapSurveyQueryParameters = new Map<String,String>();
        mapSurveyQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnSurvey);
        mapSurveyQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        List<Survey> lstSurveyRecords = new List<Survey>();
        Map<Boolean,String> mapSurveyQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Survey', sFieldsToQueryOnSurvey, mapSurveyQueryParameters);
        String switchSurveyKey = (mapSurveyQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchSurveyKey) {
            when 'success' {
                String sSurveyQuery = mapSurveyQueryResponse.get(true);
                lstSurveyRecords = Database.query(sSurveyQuery);
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','getSurveys','Some Fields doesn\'t have the required access :: '+mapSurveyQueryResponse.get(false), true);
            }
        }
        //[Suresh] Handle list has no row for assignment error
        if(!lstSurveyRecords.isEmpty()){
            return lstSurveyRecords[0];
    }
        else{
            return new Survey();
        }
    }
    /**************************************************************************************
    * @author       Megha Mittal
    * @date         10/23/2019
    * @methodname   getCommunityId()
    * @description  This methods is used to fetch CommunityId
    * @param        (String)
    * @return       String 
    ******************************************************************************************/
    public static Network getCommunityId(String CommunityName){
        String sFieldsToQueryOnCommunity = RE_DataBaseQueryFields.sFieldsToQueryOnCommunity;
        String sWhereClauseOnCommunity = RE_DataBaseQueryFields.sWhereClauseOnCommunity;
        Map<String,String> mapCommunityQueryParameters = new Map<String,String>();
        mapCommunityQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnCommunity);
        mapCommunityQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        Network lstCommunityRecords = new Network();
        Map<Boolean,String> mapCommunityQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Network', sFieldsToQueryOnCommunity, mapCommunityQueryParameters);
        String switchCommunityKey = (mapCommunityQueryResponse.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCommunityKey) {
            when 'success' {
                String sCommunityQuery = mapCommunityQueryResponse.get(true);
                lstCommunityRecords = (Network)Database.query(sCommunityQuery);
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','getCommunitys','Some Fields doesn\'t have the required access :: '+mapCommunityQueryResponse.get(false), true);
            }
        }
        return lstCommunityRecords;
    }
    /**************************************************************************************
    * @author       Megha Mittal
    * @date         10/25/2019
    * @methodname   getSurveyQuestionResponse()
    * @description  This methods is used to fetch List of SurveyQuestionResponse
    * @param        (String)
    * @return       List<SurveyQuestionResponse> 
    ******************************************************************************************/
    public static List<SurveyQuestionResponse> getSurveyQuestionResponse(String ResponseId){
        String sFieldsToQueryOnSurveyQuestionResponse = RE_DataBaseQueryFields.sFieldsToQueryOnSurveyQuestionResponse;
        String sWhereClauseOnSurveyQuestionResponse = RE_DataBaseQueryFields.sWhereClauseOnSurveyQuestionResponse;
        Map<String,String> mapResponseQueryParameters = new Map<String,String>();
        mapResponseQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnSurveyQuestionResponse);        
        List<SurveyQuestionResponse> lstResponseRecords = new List<SurveyQuestionResponse>();
        String responseQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('SurveyQuestionResponse', sFieldsToQueryOnSurveyQuestionResponse, mapResponseQueryParameters);             
        lstResponseRecords = Database.query(responseQuery);        
        return lstResponseRecords;
    }   
    /**************************************************************************************
    * @author       Megha Mittal
    * @date         10/25/2019
    * @methodname   getSurveySetting()
    * @description  This methods is used to fetch SurveySetting
    * @param        (String)
    * @return       Survey_Setting__mdt
    ******************************************************************************************/
    public static Survey_Setting__mdt getSurveySetting(String surveyName){
        String sFieldsToQueryOnSurveySetting = RE_DataBaseQueryFields.sFieldsToQueryOnSurveySetting;
        String sWhereClauseOnSurveySetting = RE_DataBaseQueryFields.sWhereClauseOnSurveySetting;
        Map<String,String> mapSurveySettingQueryParameters = new Map<String,String>();
        mapSurveySettingQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnSurveySetting);
        mapSurveySettingQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        Survey_Setting__mdt lstSettingRecords = new Survey_Setting__mdt();
        String surveySettingQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Survey_Setting__mdt', sFieldsToQueryOnSurveySetting, mapSurveySettingQueryParameters);             
        lstSettingRecords = Database.query(surveySettingQuery);        
        return lstSettingRecords;
    }
    /*********************************************************************************************************
    * @author       Payal Dubela
    * @date         11/04/2019
    * @methodname   getContactMappings()
    * @description  This methods is used to get contact mapping recordas
    * @return       List<Referral__c>
    /***********************************************************************************************************/
    public static List<Contact_Mapping__c> getContactMappings(Map<String, String> mapInputs,List<Contact> conList){
        String sQuery =  mapInputs.get('sQuery');
        return Database.query(sQuery);
    }
	/**************************************************************************************
    * @author       Megha Mittal
    * @date         11/04/2019
    * @methodname   getContact()
    * @description  This methods is used to fetch Contact
    * @param        (String)
    * @return       Contact 
    ******************************************************************************************/
    public static map<Id,Contact> getContact(List<Id> contactIds){
        String sFieldsToQueryOnContact = RE_DataBaseQueryFields.sFieldsToQueryOnContactRecord ;
        String sWhereClauseOnContact= RE_DataBaseQueryFields.sWhereClauseOnContactRecord;
        Map<String,String> mapContactQueryParameters = new Map<String,String>();
        mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnContact);                
        String responseQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Contact', sFieldsToQueryOnContact , mapContactQueryParameters );                     
        map<Id,Contact> contactRecordMap = new map<Id,Contact>((List<Contact>)Database.query(responseQuery));        
        return contactRecordMap;
    }  
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         11/13/2019
    * @methodname   getResourceIdsFromResourceLocation()
    * @description  This methods is used to fetch Contact
    * @param        (String)
    * @return       Contact 
    ******************************************************************************************/  
    public static List<LocationResource__c> getResourceIdsFromResourceLocation(Set<Id> setResLocationIds, String sQuery){
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Megha Mittal
    * @date         11/25/2019
    * @methodname   getDocumentDetails()
    * @description  This methods is used to fetch Contact
    * @param        (String)
    * @return       List<DocumentDetail> 
    ******************************************************************************************/  
    public static List<DocumentDetail__c> getDocumentDetails(String sParentId, String sQuery){
        return Database.query(sQuery);
    }
    public static List<DocumentDetail__c> getDocumentDetails(String sParentId, String sQuery, String sDocumentRecordType){
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Megha Mittal
    * @date         11/25/2019
    * @methodname   getContentDocument()
    * @description  This methods is used to fetch Contact
    * @param        (String)
    * @return       List<ContentDocument> 
    ******************************************************************************************/  
    public static List<ContentDocument> getContentDocument(set<string> lstConDocIds, String sQuery){
        return Database.query(sQuery);
    }
	/**************************************************************************************		
    * @author       Megha Mittal		
    * @date         11/21/2019		
    * @methodname   getLoggedinUserAccount()		
    * @description  This methods is used to fetch LoggedinUserAccount    		
    * @return       User 		
    ******************************************************************************************/  		
    public static user getLoggedinUserAccount(){        		
        String sUserId=userinfo.getuserId();                		
        return database.query(RE_DataBaseQueryFields.sQueryforUser);		
    }
    public static List<SurveyInvitation> fetchSurveyInvites(Id recordId){    
        String sFieldsonSurveyInvite = RE_DataBaseQueryFields.sFieldsonSurveyInvite ;
        String sWhereClauseonSurveyInvite= RE_DataBaseQueryFields.sWhereClauseonSurveyInvite;
        Map<String,String> mapInviteQueryParameters = new Map<String,String>();
        mapInviteQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseonSurveyInvite);                
        String responseQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('SurveyInvitation', sFieldsonSurveyInvite , mapInviteQueryParameters );                     
        List<SurveyInvitation> lstSurveyInvites = new List<SurveyInvitation>();
        try{
            lstSurveyInvites = Database.query(responseQuery);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','fetchSurveyInvites',e.getmessage(), true);
        }
        return lstSurveyInvites;        
    } 
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         12/23/2019
    * @methodname   getResourceTaxonomies()
    * @description  This methods is used to get the Resource Taxonomies
    * @param        (Set<String)
    * @return       List<RE_Resource_Taxonomy__c> 
    ******************************************************************************************/   
    public static List<RE_Resource_Taxonomy__c> getResourceTaxonomies(Set<String> setTaxonomyIds, String sQuery, String sAccountStatus){
        return Database.query(sQuery);
    } 
	/*********************************************************************************************************
    * @author       Megha Mittal
    * @date         12/10/2019
    * @methodname   getReferralDetails()
    * @description  This methods is used to fetch referral details after pagination is implemented
    * @return       List<Referral__c>
    /***********************************************************************************************************/
    public static List<Referral__c> getReferralDetails(Id contactId,String sPageType, Integer iPageSize,Integer pageNumber){
        String sNewStatus = RE_GlobalConstants.STATUS_NEW;
        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', 'ReferralRecord');
        String sWhereClauseOnReferral;
        if(sPageType=='MyResources'){
            sWhereClauseOnReferral=RE_DataBaseQueryFields.sWhereClauseOnReferralObjectupdatedNew;
        } else if(sPageType=='Completed'){
            sWhereClauseOnReferral=RE_DataBaseQueryFields.sWhereClauseOnReferralObjectupdatedCompleted;
        } else if(sPageType=='Suggested'){
            sWhereClauseOnReferral=RE_DataBaseQueryFields.sWhereClauseOnReferralObjectupdatedDraft;
        }
        String sFieldsToQueryOnReferral = RE_DataBaseQueryFields.sFieldsToQueryOnReferralObject;        
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;        
        iPageSize=(iPageSize!=null)?iPageSize:50000;
        Integer offSet=pageNumber*iPageSize;        
        List<Referral__c> lstReferral ;
        Map<String,String> mapLocationQueryParameters = new Map<String,String>();
        mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReferral);
        mapLocationQueryParameters.put(RE_GlobalConstants.sOrderByKey, RE_GlobalConstants.sReferralSort);
        mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, String.valueof(iPageSize));
        mapLocationQueryParameters.put(RE_GlobalConstants.sOffset, String.valueof(offSet));        
        Map<Boolean,String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Referral__c', sFieldsToQueryOnReferral, mapLocationQueryParameters);
        
        String switchCaseKey = (mapLocationQueryResponse.get(true) != null) ? 'success' : 'failure'; 
        switch on (switchCaseKey) {
            when 'success' {
                String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Referral__c', RE_DataBaseQueryFields.sFieldsToQueryOnReferralObjectToLabel, mapLocationQueryParameters);
                lstReferral = Database.query(sQuery);
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl','getWrapper','Some Fields doesn\'t have the required access :: '+mapLocationQueryResponse.get(false), true);
            }
        }
        return lstReferral;
    }
    /********************************************************************************************
    * @author       Payal Dubela(Bug:342978)
    * @date         01/10/2020
    * @methodname   getLocationResourcesCount()
    * @description  This methods is used to get the locaion resources
    * @return      Double
    **********************************************************************************************/
    public static List<AggregateResult> getLocationResourcesCount(Map<String, Object> mapInputs){
        Set<Id> setLocationResourceIds = (Set<Id>)mapInputs.get('setLocationResourceIds');
        Set<Id> setGlobalLocaResourceIds = (Set<Id>)mapInputs.get('setGlobalLocaResourceIds');
        Double dblLat = Double.valueOf(mapInputs.get('dblLat'));
        Double dblLon = Double.valueOf(mapInputs.get('dblLon'));
        String sQuery = (String)mapInputs.get('sQuery');
        Integer iRadiusMiles = Integer.valueOf(System.Label.searchmilesradius); 
        return Database.query(sQuery);
    }
    
    
   /*********************************************************************************************************
    * @author       Anuj Vashistha (Bug 345143)
    * @date         01/14/2020
    * @methodname   createUser()
    * @description  This methods is used to get Group records
    * @return       List<Group>
    /***********************************************************************************************************/
    public static List<Group> getGroup(){
        try{
            String claimSiteQueue = RE_GlobalConstants.CLAIM_SITE_QUEUE;
            Map<String, String> mapGroupQueryParameters = new Map<String, String>();
            String whereClauseCondition = RE_DataBaseQueryFields.sWhereClauseOnClaim;
            mapGroupQueryParameters.put(RE_GlobalConstants.sWhereClauseKey,whereClauseCondition );
            mapGroupQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            String groupQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Group', 'DeveloperName', mapGroupQueryParameters);
       		return Database.query(groupQuery);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_SharingByPassCtrl','getGroupId',e.getMessage()+' '+e.getStackTraceString(), true);
            throw e;
        }
    }
    /*********************************************************************************************************
    * @author       Arun Garg
    * @date         01/17/2020
    * @methodname   getTotalReferralSent()
    * @description  This method is used to get all te referral sent by organization.
    * @return       List<AggregateResult>
    /***********************************************************************************************************/
    public static List<AggregateResult> getTotalReferralSent(String loggedInAccountId){
        List<AggregateResult> totalReferralSent;
        //RE_Release 1.4 – IronDome Fixes- Payal Dubela
        if (Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && Schema.sObjectType.Referral__c.fields.Name.isAccessible()
        && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() ) {
        totalReferralSent = [SELECT COUNT(Name) totalref,CALENDAR_MONTH(DateOfReferral__c) month,CALENDAR_year(DateOfReferral__c) Year FROM Referral__c where ReferredByAccountID__c=:loggedInAccountId AND (DateOfReferral__c=LAst_N_Months:4 or DateOfReferral__c =THIS_Month ) GROUP BY CALENDAR_YEAR(DateOfReferral__c), CALENDAR_MONTH(DateOfReferral__c) ORDER BY CALENDAR_YEAR(DateOfReferral__c), CALENDAR_MONTH(DateOfReferral__c) ASC ];
        }
    	return totalReferralSent;
    }
    public static List<AggregateResult> getReferralsMade(String loggedInAccountId){
        List<AggregateResult> referralsMade;
        //RE_Release 1.4 – IronDome Fixes- Payal Dubela
        if (Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && Schema.sObjectType.Referral__c.fields.Name.isAccessible()
        && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() ) {
        referralsMade = [SELECT COUNT(Name) FROM Referral__c where ReferredByAccountID__c=:loggedInAccountId AND (DateOfReferral__c=LAst_N_Months:4 or DateOfReferral__c =THIS_Month)];
        }
    	return referralsMade;
    }
    public static List<AggregateResult> getMostReferredByOrg(String loggedInAccountId){
        List<AggregateResult> mostReferredByOrg;
        //RE_Release 1.4 – IronDome Fixes- Payal Dubela
        if (Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && Schema.sObjectType.Referral__c.fields.Name.isAccessible()
        && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() ) {
        mostReferredByOrg = [SELECT ReferredByAccountID__r.Name,COUNT(Name) FROM Referral__c where ReferredByAccountID__c=:loggedInAccountId and ReferredByAccountID__r.Name!=null and (DateOfReferral__c=LAst_N_Months:4 or DateOfReferral__c =THIS_Month) Group By ReferredByAccountID__r.Name Order By Count(Name) Desc Limit 5];
        }
    	return mostReferredByOrg;
    }

    /**************************************************************************************
    * @author       Payal Dubela
    * @date         10/15/2019
    * @methodname   getContacts()
    * @description  This methods is used to get contact 
    * @param        (String sQuery,Set<Id>)
    * @return       List<Contentversion> 
    ******************************************************************************************/
    public static List<Contact> getClients(String sQuery,Date userInputDate,String sRecordType,Map<String, String> mapInputs){
        //RE Security Changes -- Payal Dubela
        String sNonCitizenRecordType=mapInputs.get('sNonCitizenRecordType');
        String citizenRole=RE_GlobalConstants.sPercentage+RE_GlobalConstants.strCitizenAppRole+RE_GlobalConstants.sPercentage;
        return Database.query(sQuery);
    }  
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         10/15/2019
    * @methodname   checkLocationRes()
    * @description  This methods is used to get contact 
    * @param        (String sQuery,Set<Id>)
    * @return       List<LocationResource__c> 
    ******************************************************************************************/
    public static List<LocationResource__c> checkLocationRes(String sQuery,String locationrecId,String resourceId){
        return Database.query(sQuery);
    }


/**************************************************************************************
    * @author       Prashant Singh
    * @date         04/01/2020
    * @methodname   getResourceIdsFromResourceLocation()
    * @description  This methods is used to fetch Contact
    * @param        (String)
    * @return       Contact 
    ******************************************************************************************/  
    public static List<SDOH__c> fetchRiskFactors(String clientId, String sQuery){
        return Database.query(sQuery);
    }    
     /*********************************************************************************************************
    * @author       Prashant Singh
    * @date         06/14/2019
    * @methodname   getReferralcountforPlan()
    * @description  This methods is used to fetch referral details
    * @return       List<Referral__c>
    /***********************************************************************************************************/
    public static List<Referral__c> getReferralcountforPlan(Id contactId){
        String sNewStatus = RE_GlobalConstants.STATUS_NEW;
        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', 'ReferralRecord');
        String sFieldsToQueryOnReferral = RE_DataBaseQueryFields.sFieldsToQueryreferralcount;
        String sWhereClauseOnReferral = RE_DataBaseQueryFields.sWhereClauseOnReferralObject;
        String sAccountStatus = RE_GlobalConstants.sAccountStatus;
        List<Referral__c> lstReferral ;
        Map<String,String> mapLocationQueryParameters = new Map<String,String>();
        mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReferral);
        mapLocationQueryParameters.put(RE_GlobalConstants.sOrderByKey, RE_GlobalConstants.sReferralSort);
        mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        Map<Boolean,String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Referral__c', sFieldsToQueryOnReferral, mapLocationQueryParameters);
        
        String switchCaseKey = (mapLocationQueryResponse.get(true) != null) ? 'success' : 'failure'; 
        switch on (switchCaseKey) {
            when 'success' {
               // String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Referral__c', RE_DataBaseQueryFields.sFieldsToQueryOnReferralObjectToLabel, mapLocationQueryParameters);
                 String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Referral__c', sFieldsToQueryOnReferral, mapLocationQueryParameters);
                
                lstReferral = Database.query(sQuery); 
               // 
               // 
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserCtrl','getWrapper','Some Fields doesn\'t have the required access :: '+mapLocationQueryResponse.get(false), true);
            }
        }
        return lstReferral;
    }
   /*********************************************************************************************************
    * @author       Nandita Bapaye
    * @date         04/15/2020
    * @methodname   getClientSDOH()
    * @description  This methods is used to fetch SDOH details
    * @return       List<SDOH__c>
    /***********************************************************************************************************/
   
    /**************************************************************************************
* @author       Payal Dubela
* @date         10/15/2019
* @methodname   getUsersList for Profile
* @description  This methods is used to get Users for a profile
* @param        String strProfileName
* @return       List<User> 
******************************************************************************************/
    public static List<User> getUserList(String sProfileName){
        String sFieldsToQueryOnProfile = RE_DataBaseQueryFields.sFieldsToQueryOnProfile;
        String sWhereClauseOnProfile = RE_DataBaseQueryFields.sWhereClauseOnProfile;
        String sProfileQuery;
        String sUserQuery;
        Map<String,String> mapProfileQueryParameters = new Map<String,String>();
        mapProfileQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnProfile);
        mapProfileQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        mapProfileQueryParameters.put(RE_GlobalConstants.sOrderByKey,RE_DataBaseQueryFields.sOrderByUser);
        sProfileQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Profile', sFieldsToQueryOnProfile, mapProfileQueryParameters);            
        Profile objProfile = Database.query(sProfileQuery);
        String profileId=objProfile.Id;
        String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUserForSystemAutoProcess;
        String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseForUserForSystemAutoProcess;
        Map<String,String> mapQueryParameters = new Map<String,String>();
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,RE_DataBaseQueryFields.sOrderByUser);
        sUserQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.userobjectName, sFieldsToQueryOnUser, mapQueryParameters);
        List<User> userList= Database.query(sUserQuery);
        
        return userList;
    }
     public static List<SDOH__c> getClientSDOH(String clientId, String sQuery,Set<String> setSDOHCats){
        //
        return Database.query(sQuery);
    } 
/**************************************************************************************
* @author       Anuj
* @date         04/22/2020 #361790
* @methodname   getAccountRecords()
* @description  This methods is used to get Account record
* @param        (String sQuery, String orgId)
* @return       List<Account> 
******************************************************************************************/
    public static List<Account> getAccountRecords(String sQuery, String orgId){
        return Database.query(sQuery);
    }
    
    /********************************************************************************************
* @author       Anuj
* @date         04/23/2020 #361790
* @methodname   getReferralCountUnclaimedOrg()
* @description  This methods is used to get the referral count on Organization
* @return       
**********************************************************************************************/
    public static List<AggregateResult> getReferralCountUnclaimedOrg(Set<Id> setOrgId){
        List<AggregateResult> results = new List<AggregateResult>();
        if (Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible()){
            results = [SELECT COUNT(Id) cnt, ReferredAccountID__c rid FROM Referral__c WHERE ReferredAccountID__c IN:setOrgId GROUP BY ReferredAccountID__c];
        }
        return results;
    } 
    
    /**************************************************************************************
* @author       Anuj
* @date         04/23/2020 #361790
* @methodname   getAccountRecords()
* @description  This methods is used to get List of Account records
* @param        (String sQuery, String orgId)
* @return       List<Account> 
******************************************************************************************/
    public static List<Account> getAccountList(String sQuery, Set<Id> orgIds){
        return Database.query(sQuery);
    }
    
    /**************************************************************************************
* @author       Anuj
* @date         04/23/2020 #361790
* @methodname   getAccountRecords()
* @description  This methods is used to get List of Account records
* @param        (String sQuery, String orgId)
* @return       List<Account> 
******************************************************************************************/
    public static List<Resource__c> getResourceListUnclaimedOrg(Set<Id> orgIds){
        List<Resource__c> resources = new List<Resource__c>();
        if (Schema.sObjectType.Resource__c.fields.Organization__c.isAccessible()){
            resources = [Select Id,Organization__c FROM Resource__c WHERE Organization__c IN:orgIds ];
        }
        return resources;
    }
    
    /**************************************************************************************
* @author       Anuj
* @date         04/23/2020 #361790
* @methodname   getLocationList()
* @description  This methods is used to get List of Location records
* @param        (String sQuery, String orgId)
* @return       List<Account> 
******************************************************************************************/
    public static List<Location__c> getLocationList(String sQuery, Set<Id> orgIds){
        return Database.query(sQuery);
    }
/**************************************************************************************
* @author       Srikanth
* @date         04/24/2020 
* @methodname   createReferralForSuggestedThanks()
* @description  This methods is used to create referral based on the option user select on UI
* @param        (RE_MyPlanWrapper wrapper, String strValueHandler)
* @return       LocationResource__c
******************************************************************************************/    
   
    public static LocationResource__c createReferralForSuggestedThanks( Map<String, Object> mapRsrce, String strValueHandler){
         
        Id loggedinUserId = UserInfo.getUserId();
        contact con;
        Resource__c res;
        Location__c loc;
        LocationResource__c locres;
        
        Map<String, Object> objCon  = (Map<String, Object>)mapRsrce.get('con');
        Map<String, Object> objRes = (Map<String, Object>)mapRsrce.get('resource');
        Map<String, Object> objLoc = (Map<String, Object>)mapRsrce.get('location');
        
        if (Schema.sObjectType.Account.fields.Status__c.isAccessible() && Schema.sObjectType.Account.fields.IsClaimed__c.isAccessible() ){  String strContactId = (String)objCon.get('sResidentId');
            con = [SELECT Id,Account.Status__c,Account.IsClaimed__c FROM Contact WHERE Id=:strContactId LIMIT 1];
        }
        if (Schema.sObjectType.Resource__c.fields.Id.isAccessible() && Schema.sObjectType.Resource__c.fields.Organization__c.isAccessible() ){
            String strResId = (String)objRes.get('resourceId');
            res = [SELECT Id,Organization__r.Status__c,Organization__r.IsClaimed__c FROM Resource__c WHERE Id=:strResId LIMIT 1];
        }
        if (Schema.sObjectType.Location__c.fields.Id.isAccessible() ){
            String sLocationId = (String)objLoc.get('sLocationId');
            loc = [SELECT Id FROM Location__c WHERE Id=:sLocationId LIMIT 1];
        }
        if (Schema.sObjectType.LocationResource__c.fields.Id.isAccessible() ){
            locres = [SELECT Id FROM LocationResource__c WHERE Resource__c=:res.Id AND Location__c=:loc.Id LIMIT 1];
        }
        User usr = [SELECT Id FROM User WHERE id=:loggedinUserId LIMIT 1];
        Referral__c refRec = new Referral__c();
        if(strValueHandler == RE_GlobalConstants.CONNECT && res.Organization__r.Status__c == RE_GlobalConstants.sAccountStatus && res.Organization__r.IsClaimed__c == True){
            refRec.Status__c = RE_GlobalConstants.STATUS_NEW;
            refRec.UserComplete__c = false;
	    refRec.CartAction__c = RE_GlobalConstants.ACCEPTED;
        }
        else if(strValueHandler == RE_GlobalConstants.CONNECT && res.Organization__r.IsClaimed__c == False){
            refRec.Status__c = RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
            refRec.UserComplete__c = false;
            refRec.CartAction__c = RE_GlobalConstants.ACCEPTED;
        }
        if(strValueHandler == RE_GlobalConstants.NO_THANKS){
            refRec.Status__c = RE_GlobalConstants.REFERRAL_STATUS_CLOSED;
            refRec.Outcome__c = RE_GlobalConstants.REFERRAL_OUTCOME_STATUS;
            refRec.OutcomeReason__c = RE_GlobalConstants.REFERRAL_CANCELLED_BY_CLIENT;
            refRec.CartAction__c = RE_GlobalConstants.DECLINED;
            refRec.UserComplete__c = true;
            refRec.DateClosed__c = System.today();
        }
        refRec.Contacts__c = con.Id;
        refRec.DateOfReferral__c = System.today();
        refRec.Source__c = RE_GlobalConstants.SUGGESTED_BY_SYSTEM;
        refRec.Resource__c = res.Id;
        refRec.Location__c = loc.Id;
        refRec.ReferredAccountID__c = res.Organization__c;
        if(Schema.sObjectType.Referral__c.isCreateable()){
            try{
               Insert refRec; 
            }
            catch(exception e){
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl', 'createReferralForSuggestedThanks', e.getMessage(), true);
            }
        }
       
        return locres;
    }
    
/**************************************************************************************
* @author       Srikanth
* @date         04/24/2020 
* @methodname   deleteRecommendations()
* @description  This methods is used to delete the Recommendations by Citizen 
* @param        (List<ReferralRecommendation__c> lstRefRec)
* @return       void
******************************************************************************************/    
    public static void deleteRecommendations(List<ReferralRecommendation__c> lstRefRec){
        if(Schema.sObjectType.ReferralRecommendation__c.isDeletable()){
            try{
               delete lstRefRec;
            }
            catch(exception e){
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl', 'deleteRecommendations', e.getMessage(), true);
            }
        }
    }

/**************************************************************************************
* @author       Srikanth
* @date         04/24/2020 
* @methodname   getResourcesRecommendations()
* @description  This methods is used to retirve Location Resourse based on the Id's received from API call 
* @param        (set<Id> setIds)
* @return       List<LocationResource__c>
******************************************************************************************/        
    public static List<LocationResource__c> getResourcesRecommendations(set<Id> setIds){
        List<LocationResource__c> lstLocRes = new List<LocationResource__c>();
        if (Schema.sObjectType.LocationResource__c.fields.Resource__c.isAccessible() && Schema.sObjectType.LocationResource__c.fields.Location__c.isAccessible()  ){
            lstLocRes = [Select Id,Resource__c,Location__c FROM LocationResource__c 
                         WHERE Id IN:setIds AND Status__c =: RE_GlobalConstants.USER_STATUS_ACTIVE];
        }
        return lstLocRes;
    
    }   
/**************************************************************************************
* @author       Srikanth
* @date         04/24/2020 
* @methodname   getLocationResourceRecmds()
* @description  This methods is used to retirve Location Resourse based on the Id's received from API call 
* @param        (String strContactId)
* @return       set<String>
******************************************************************************************/            
    public static set<String> getLocationResourceRecmds(String strContactId){
        
        set<Id> setResourceIdsRequest = new set<Id>();
        set<string> setStrLocResRequest = new set<string>();
        
        if (Schema.sObjectType.Referral__c.fields.Resource__c.isAccessible() ){
            for(Referral__c refReq : [SELECT Id,Name,Resource__c,Contacts__c FROM Referral__c WHERE Contacts__c=:strContactId AND  CreatedDate = LAST_N_DAYS:7]){
                setResourceIdsRequest.add(refReq.Resource__c);
            } 
        }
        if (Schema.sObjectType.LocationResource__c.fields.Id.isAccessible() ){
            for(LocationResource__c locResourceReq : [Select Id FROM LocationResource__c 
                                                      WHERE Resource__c IN:setResourceIdsRequest]){
                                                          setStrLocResRequest.add(String.ValueOf(locResourceReq.Id));   
                                                      }  
        }
        
        return setStrLocResRequest;
    }
    
/**************************************************************************************
* @author       Srikanth
* @date         04/24/2020 
* @methodname   getCountValue()
* @description  This methods is used to retirve count of the Recommendations available based on the conditions
* @param        N/A
* @return       integer
******************************************************************************************/         
    
    public static integer getCountValue(string strContactId){ 
        
        String contactId;  
        String sProfileName = GeneralUtility.getLoggedInUserProfile().Name;
        // SSP Merge Fixes-- Kojashree
        String sRole = GeneralUtility.getLoggedInUserSelectedRole();
        //   if(sProfileName == RE_GlobalConstants.strCitizenProfileName){
        if(sRole == RE_GlobalConstants.strCitizenAppRole){
            // if profile is citizen dont allow to pass any other contact id
            contactId = GeneralUtility.getLoggedInUserContactId();
        }else{
            contactId = (String.isBlank(strContactId)) ? GeneralUtility.getLoggedInUserContactId() : strContactId;
        }
        
        List<User> lstUser = new List<User>();
        //RE_Release 1.4 – IronDome Fixes- Payal Dubela
        if(Schema.sObjectType.User.fields.Id.isAccessible()){
            lstUser=[SELECT Id FROM User WHERE ContactId =:contactId ];
        }
        integer countValue = 0;  
        
        set<Id> countValueTest = new set<Id>();
        
           
            Id loggedinUserId = !lstUser.isEmpty() ? lstUser[0].Id : UserInfo.getUserId();
            set<Id> setidsLocationRes = new set<Id>(); 
            set<Id> setResourceIdsRequest =new set<Id>();
            set<Id> setResourcesIdsFromLoc = new Set<Id>();
            
            
            if (Schema.sObjectType.ReferralRecommendation__c.fields.LocationResource__c.isAccessible() && Schema.sObjectType.ReferralRecommendation__c.fields.User__c.isAccessible() ){
                for(ReferralRecommendation__c ReRcomd : [Select Id,Name,LocationResource__c,User__c FROM ReferralRecommendation__c WHERE User__c=:loggedinUserId ] ){
                    setResourceIdsRequest.add(ReRcomd.LocationResource__c);
                }
            }
            
            if (Schema.sObjectType.LocationResource__c.fields.Location__c.isAccessible() && Schema.sObjectType.LocationResource__c.fields.Resource__c.isAccessible() ){
                for(LocationResource__c locResourceReq : [Select Id,Location__c,Resource__c,Location__r.Account__c,Resource__r.Organization__c,Resource__r.Organization__r.Status__c FROM LocationResource__c 
                                                          WHERE Id IN:setResourceIdsRequest and Status__c =: RE_GlobalConstants.USER_STATUS_ACTIVE]){
                                                              if(locResourceReq.Resource__r.Organization__r.Status__c == RE_GlobalConstants.sAccountStatus){
                                                                  setResourcesIdsFromLoc.add(locResourceReq.Resource__c);
                                                                  countValueTest.add(locResourceReq.Id);
                                                              }                                      
                                                          }  
            }
      
        countValue = countValueTest.size();
        return countValue;
    }
    
    
    public static List<LocationResource__c> lstLocationResource(set<Id> setLocationResourcesIds){
        List<LocationResource__c> lstLocRes = [SELECT Id,Name,Notes__c,Location__r.Notes__c,ResourceDescription__c,WhatToBring__c,
                                          EligibilityDescription__c,NextSteps__c,Fees__c,Resource__c,Resource__r.Organization__r.Name,
                                          Resource__r.Name,Resource__r.SdohDomain__c,Resource__r.Organization__r.IsClaimed__c,
                                          Resource__r.Organization__r.Website,Resource__r.Organization__r.ShippingStreet,
                                          Resource__r.Organization__r.ShippingCity,Resource__r.Organization__r.ShippingPostalCode,
                                          Location__r.Address1__c,Location__r.Address2__c,Location__r.City__c,Location__r.State__c,
                                          Location__r.County__c,Location__r.Zip__c,Location__r.ZipExtensionCode__c,Location__r.Email__c,
                                          Location__r.Account__r.Email__c,Location__r.LocationWebsite__c,Location__r.Account__r.Website,
                                          Location__r.Name,Location__c,Location__r.SpecialLocationInstructions__c,Phone__c,TollFree__c,
                                          Location__r.Geolocation__latitude__s,Location__r.Geolocation__longitude__s,Resource__r.Organization__c,
                                          Resource__r.CreatedBy.Name,Resource__r.DaysSinceOpened__c,Location__r.Geolocation__c FROM LocationResource__c WHERE Id IN:setLocationResourcesIds AND Status__c='Active' AND Resource__r.Organization__r.Status__c='Active - Allow referrals' ];
        return lstLocRes;
    }
    
    public static List<ReferralRecommendation__c> RequestRecommendations(Id UserId){
     //RE_Release 1.4 – IronDome Fixes- Payal Dubela
      if (Schema.sObjectType.ReferralRecommendation__c.fields.LocationResource__c.isAccessible() 
          && Schema.sObjectType.ReferralRecommendation__c.fields.User__c.isAccessible()
          && Schema.sObjectType.ReferralRecommendation__c.fields.DaysSinceOpened__c.isAccessible()){
        return [SELECT LocationResource__c,User__c,DaysSinceOpened__c FROM ReferralRecommendation__c WHERE User__c=:UserId];
      }else{
          return new List<ReferralRecommendation__c>();
      }
    }

    /**************************************************************************************
    * @author       Payal Dubela
    * @date         04/22/2020
    * @methodname   getLocationResourceRecords()
    * @description  This methods is used to fetch LocationResources
    * @param        (String)
    * @return       Contact 
    ******************************************************************************************/  
    public static List<LocationResource__c> getLocationResourceRecords(Set<String> locationResourceIds, String sQuery,String sActiveStatus,String sActiveAllowReferral){
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         04/23/2020 #361790
    * @methodname   getOrganizationDetails()
    * @description  This methods is used to get Account record
    * @param        (String sQuery, String accId)
    * @return       List<ContentDocumentLink> 
    ******************************************************************************************/
    public static List<Account> getOrganizationDetails(String sQuery, String orgId){
        return Database.query(sQuery);
    }

    //Moved to sharingbypass because contact does not have sharing in same thread were it is created
    public static Contact getContactDetails(String sQuery,Id clientId){
        return Database.query(sQuery);
    }

     //Moved to sharingbypass because contact does not have sharing in same thread were it is created
     public static Map<String,List<Contact>> getDuplicateContacts(List<String> sEmail){
        Map<String,List<Contact>> mapEmailWithContact = new Map<String,List<Contact>>();
        String sContactStatus=RE_GlobalConstants.ACTIVE;
        if (Schema.sObjectType.Contact.fields.PermissionsLevel__c.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible() && Schema.sObjectType.Contact.fields.Phone.isAccessible()
        && Schema.sObjectType.Contact.fields.Id.isAccessible()){
         for(Contact con:[SELECT ID, PermissionsLevel__c,RecordTypeId,
                          Email,Account.Applicable_Roles__c,AccountId,Phone,Status__c 
                          FROM Contact WHERE Email=:sEmail]){         
              if(!mapEmailWithContact.containsKey(con.Email)){
                mapEmailWithContact.put(con.Email,new List<Contact>());
              }
              mapEmailWithContact.get(con.Email).add(con);
          }
        } 
        return mapEmailWithContact;
    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         08/12/2020
    * @methodname   getContactRecords()
    * @description  This methods is used to get Account record
    * @param        (String sQuery, String accId)
    * @return       List<ContentDocumentLink> 
    ******************************************************************************************/
    public static List<Object> getContactRecords(String sQuery, Map<String,String> mapInputs){
        String nonCitizenRecordTypeId=mapInputs.get('nonCitizenRecordTypeId');
        String cpAdminRole=mapInputs.get('cpAdminRole');
        String cpStaffRole=mapInputs.get('cpStaffRole');
        String agencyAdminRole=mapInputs.get('agencyAdminRole');
        String agencyStaffRole=mapInputs.get('agencyStaffRole');
        String recordId=mapInputs.get('recordId');
        String sAccountId=mapInputs.get('sAccountId');
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         08/12/2020
    * @methodname   getContactWrapper()
    * @description  This methods is used to get Account record
    * @param        (String sQuery, String accId)
    * @return       List<ContentDocumentLink> 
    ******************************************************************************************/
    public static Contact getContactWrapper(String sQuery, Map<String,String> mapInputs){
        String contactRecordTypeId=mapInputs.get('contactRecordTypeId');
        String sContactId=mapInputs.get('sContactId');
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Venkat Korra
    * @date         08/12/2020
    * @methodname   updateObjects()
    * @description  This methods is used to update contact record
    * @param        (Schema.SobjectType objectType, List<Sobject> lstObjects)
    * @return       List<Contact> 
    ******************************************************************************************/
    public static Database.SaveResult[] updateObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) 
    {
        Database.SaveResult[] lstSaveResults;
        try{
            lstSaveResults = Database.update(lstObjects, true);
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl', 'updateObjects', e.getMessage(), true);
        }
        return lstSaveResults;
    }
    /*****************************************************************************************************
    * @author        Venkat Korra
    * @date          08/07/2020
    * @methodname    getACRRecord()
    * @description   This method is used for fetching AccountContactRelation record
    * @return        AccountContactRelation
    * @param		 contactId, selectedRole
    *******************************************************************************************************/
    public static AccountContactRelation getACRRecord(String contactId, String selectedRole,Boolean bActive){
        String sAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
        AccountContactRelation acrRecord;
        List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
        try{
            if(RE_DataAccessChecker.isAllowedToAccess(AccountContactRelation.sObjectType)){ // PMD Report Check.
                String sFieldsToQueryOnACR = RE_DataBaseQueryFields.sFieldsToQueryOnACR;
                //RE Security Changes -392204-Payal Dubela
                String sWhereClauseOnACR = bActive==true?RE_DataBaseQueryFields.sWhereClauseForACRGetOrg:RE_DataBaseQueryFields.sWhereClauseForACRGetOrg1;
                Map<String,String> mapACRQueryParameters = new Map<String,String>();
                mapACRQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnACR);
                Map<Boolean,String> mapACRQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('AccountContactRelation', sFieldsToQueryOnACR, mapACRQueryParameters);
                String switchUserKey = (mapACRQueryResponse.get(true) != null) ? 'success' : 'failure';    
                switch on (switchUserKey) {
                    when 'success' {
                        lstACR = Database.query(mapACRQueryResponse.get(true));
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInAccountId','Some Fields doesn\'t have the required access :: '+mapACRQueryResponse.get(false), true);
                    }
                }
            }
            if(lstACR.size() > 0){
                acrRecord = lstACR[0];
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'GeneralUtility', 'getLoggedInAccountId', '****No Account Found for Logged in User****' , true);
        }
        return acrRecord;
    }
    /**************************************************************************************
    * @author       Venkat Korra
    * @date         08/12/2020
    * @methodname   deleteACRRecord()
    * @description  This methods is used to update contact record
    * @param        (Set<Id> setOfacrIds)
    * @return       void 
    ******************************************************************************************/
    @future
    public static void deleteACRRecord(Set<Id> setOfacrIds) 
    {
        try{
            List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation WHERE Id IN :setOfacrIds];
            if(acrList.size() > 0){
                delete acrList;
            }
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl', 'deleteACRRecord', e.getMessage(), true);
        }
    }
    //Moved to sharingbypass because contact does not have sharing in same thread were it is created
    public static List<User> getUserDetails(String sQuery, String referredAccountID){
        String communityAdminRolename=RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        String agencyAdminRoleName=RE_GlobalConstants.CASE_WORKER_SUPERVISOR;
        String communityStaffRolename=RE_GlobalConstants.COMMUNITY_PARTNER_STAFF;
        String agencyStaffRoleName=RE_GlobalConstants.CASE_WORKER;
        return Database.query(sQuery);
    }
    //Moved to sharingbypass because contact does not have sharing in same thread were it is created
    public static Contact getContactRecords(String sQuery,String strContactId){
        return Database.query(sQuery);
    }
    //Moved to sharingbypass because contact does not have sharing in same thread were it is created
    public static List<User> getUserRecords(String sQuery,Id loggedinUserId){
        return Database.query(sQuery);
    }
    //Venkat: 9/23/2020: 394512: Moved to sharingbypass because contact does not have sharing in same thread were it is created
    public static void updateReferralRecords(Referral__c objReferral){
        RE_DataAccessChecker.updateObject(Referral__c.getSObjectType(), objReferral);
    }
    //Moved to sharingbypass because contact does not have sharing in same thread were it is created
    public static Contact getContactDetails(String sQuery,String clientId){
        return Database.query(sQuery);
    }

    public static List<Contact> getContacts(List<Contact> lstContact){
        return [SELECT ID, PermissionsLevel__c, Email,Account.Applicable_Roles__c,recordTypeId, Phone FROM Contact WHERE ID IN : lstContact];
    }

    public static Map<Id,AccountContactRelation> getACR(List<Contact> lstContact,String sAccountId){
        String cpAdminRole=RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        String cpStaffRole=RE_GlobalConstants.COMMUNITY_PARTNER_STAFF;
        Map<Id,AccountContactRelation> acrMap= new Map<Id,AccountContactRelation>();
        for(AccountContactRelation acr : [SELECT Id,IsActive,ContactId from AccountContactRelation 
                                          where AccountId=:sAccountId AND ContactId IN:lstContact AND
                                          (Roles includes (:cpAdminRole) OR 
                                          Roles includes (:cpStaffRole))]){
            acrMap.put(acr.ContactId,acr);
        }
        return acrMap;
    }
     /**************************************************************************************
    * @author       Venkat Korra
    * @date         08/12/2020
    * @methodname   updateObjects()
    * @description  This methods is used to update contact record
    * @param        (Schema.SobjectType objectType, List<Sobject> lstObjects)
    * @return       List<Contact> 
    ******************************************************************************************/
    public static Database.SaveResult[] insertObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) 
    {
        Database.SaveResult[] lstSaveResults;
        try{
            lstSaveResults = Database.insert(lstObjects, true);
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl', 'insertObjects', e.getMessage(), true);
        }
        return lstSaveResults;
    }

     /**************************************************************************************
    * @author       Payal Dubela
    * @date         09/09/2020
    * @methodname   getDuplicateUser()
    * @description  This methods is used to get Contact record
    ******************************************************************************************/
    public static List<AggregateResult> getDuplicateUser(String sQuery, Map<String,String> mapInputs,List<String> lstEmails){
        String nonCitizenRectypeId=mapInputs.get('nonCitizenRectypeId');
        String cpAdminRole=mapInputs.get('cpAdminRole');
        String cpStaffRole=mapInputs.get('cpStaffRole');
        return Database.query(sQuery);
    }

     /*****************************************************************************************************
    * @author        Payal Dubela
    * @date          09/11/2020
    * @methodname    getInactiveACRRecord()
    * @description   This method is used for fetching AccountContactRelation record
    * @return        AccountContactRelation
    * @param         contactId, selectedRole
    *******************************************************************************************************/
    public static AccountContactRelation getInactiveACRRecord(String contactId, String selectedRole){
        String sAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strReAccRecordTypeName).getRecordTypeId();
        AccountContactRelation acrRecord;
        String cpAdminRole=RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN;
        String cpStaffRole=RE_GlobalConstants.COMMUNITY_PARTNER_STAFF;
        List<AccountContactRelation> lstACR = new List<AccountContactRelation>();
        try{
            if(RE_DataAccessChecker.isAllowedToAccess(AccountContactRelation.sObjectType)){ // PMD Report Check.
                String sFieldsToQueryOnACR = RE_DataBaseQueryFields.sFieldsToQueryOnACR;
                String sWhereClauseOnACR = RE_DataBaseQueryFields.sWhereClauseForInactiveACRGetOrg;
                Map<String,String> mapACRQueryParameters = new Map<String,String>();
                mapACRQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnACR);
                Map<Boolean,String> mapACRQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('AccountContactRelation', sFieldsToQueryOnACR, mapACRQueryParameters);
                String switchUserKey = (mapACRQueryResponse.get(true) != null) ? 'success' : 'failure';    
                switch on (switchUserKey) {
                    when 'success' {
                        lstACR = Database.query(mapACRQueryResponse.get(true));
                    }
                    when 'failure' {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'GeneralUtility','getLoggedInAccountId','Some Fields doesn\'t have the required access :: '+mapACRQueryResponse.get(false), true);
                    }
                }
            }
            if(lstACR.size() > 0){
                acrRecord = lstACR[0];
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'RE_SharingByPassCtrl', 'getInactiveACRRecord', '****No Account Found for Logged in User****' , true);
        }
        return acrRecord;
    }
    //Moved to sharingbypass because cosnent does not have sharing in same thread were it is created
    public static List<Consent__c> getActiveConsents(String sQuery,String contactId){
        return Database.query(sQuery);
    }
    //Moved to sharingbypass because consent does not have sharing in same thread were it is created
    public static List<Consent__c> getPendingConsents(String sQuery,String contactId,List<String> lstConsentLevel){
        return Database.query(sQuery);
    }
    //Moved to sharingbypass because consent does not have sharing in same thread were it is created
    public static List<Consent__c> getConsentsToRemove(String sQuery,List<String> lstConsentLevel,List<String> lstConsentStatus,String userContactId){
        return Database.query(sQuery);
    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         09/29/2020
    * @methodname   deleteSobject()
    * @description  This methods is used to delete record
    * @param        (Schema.SobjectType objectType, List<Sobject> lstObjects)
    ******************************************************************************************/
    public static Database.DeleteResult[] deleteObjects(Schema.SobjectType objectType, List<Sobject> lstObjects) 
    {
        Database.DeleteResult[] lstdeleteResults;
        try{
            lstdeleteResults = Database.delete(lstObjects, true);
        }catch(exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_SharingByPassCtrl', 'deleteObjects', e.getMessage() + ' ' +e.getStackTraceString(), true);
        }
        return lstdeleteResults;
    }
}