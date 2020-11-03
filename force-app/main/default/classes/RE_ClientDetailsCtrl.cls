/**
* Class Name    : RE_ClientDetailsCtrl
* Owner         : DELOITTE
* Created Date  : 04/06/2019
* Description   : Controller class for Client Details
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  04/06/2019  Payal           Initial Version.
*  07/24/2019  Abhijeet        Added method to fetch consent of client with status
*  07/29/2019  Deeksha         Added method to send email from client oneview
*  09/03/2019  Karthik         Added Changes to mark Notes Public or Private
*  12/04/2019  Payal           Adding changes to query SDOH picklist values for IEESData
**/
public with sharing class RE_ClientDetailsCtrl{
    
    /**************************************************************************************
* @author       Payal Dubela
* @date         11/06/2019
* @methodname   fetchClientDetails()
* @description  This methods is used to get client detaila on basis of client id
* @param        String clientId
* @return       RE_CreateLightningServerResponse 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchClientDetails(String strClientId) {
        
        String clientId = String.isNotBlank(strClientId)?String.escapeSingleQuotes(strClientId):'';
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<String, String> addressMap = new Map<String, String>();
        String sQuery;
        Contact contactDetails=new Contact();
        Contact_Mapping__c latestMapping= new Contact_Mapping__c();
        Map<String,Object> mapInputData = new Map<String,Object>();
        Re_ClientViewWrapper wrapIEESResponseData;
        Re_ClientViewWrapper.IndividualData clientData;
        Boolean hasError=false;
        List<EnrolledProgramsWrapper> lstWrapprEnrollProgs =new List<EnrolledProgramsWrapper>();
        List<HouseholdCompositionWrapper> lstWrapprHouseholdComp = new List<HouseholdCompositionWrapper>();
        Profile sProfile = GeneralUtility.getLoggedInUserProfile();
        String sRoleName = GeneralUtility.getLoggedInUserSelectedRole();
        Boolean bIsAgencyUser = false;
        Boolean hasActiveConsent;
        Boolean hasConsentToView;
        try {
            //RE_Release 1.2 – SIT Error Log- Payal Dubela– Fixing error log(After cut to production)
            if(clientId!='' && sProfile.Name!='System Administrator'){
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnClientContact;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnClientContact;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strSobjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    contactDetails = RE_SharingByPassCtrl.getContactDetails(sQuery, clientId);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchClientDetails','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            //code added for Send Email - Deeksha
            if(contactDetails.OptOutComm__c == true){
                mapResponse.put('optOutComm',true);
            }
            mapResponse.put('clientContactEmail',contactDetails.Email);
            mapResponse.put('clientName',contactDetails.Name);
            
            // Code to get the Table Data from IEES - Start - Suyash Singhal
            List<Contact_Mapping__c> mappingList=new List<Contact_Mapping__c> ();
            mappingList=RE_ClientsHelper.getContactMappings(new List<Contact>{contactDetails});
  
            if((!mappingList.isEmpty()) && mappingList.size() >0){
                latestMapping=mappingList[0];
                mapInputData.put('individualId',latestMapping.IEES_Id__c);
                REIntegrationCodes__c oIntCodes = REIntegrationCodes__c.getValues('SuccessCode');
                Map<String, Object> IEESReponse=RE_ServiceHandler.handleExecutionResults('GetClientDetails',mapInputData);                
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyieesdata = (IEESReponse.containskey(RE_GlobalConstants.RESP_CLIENT_DATA)) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                switch on (switchCaseKeyieesdata) {
                    when SWITCH_SUCCESS {                
                        wrapIEESResponseData = (Re_ClientViewWrapper)IEESReponse.get(RE_GlobalConstants.RESP_CLIENT_DATA);
                        RE_GlobalConstants.SWITCH_CONSTANTS switchErrorData = (wrapIEESResponseData.errorData!=null && wrapIEESResponseData.errorData.errorCode!=oIntCodes.Code__c) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS  ;                                                                                            
                        switch on (switchErrorData) {
                         when SWITCH_SUCCESS {           
                        clientData=wrapIEESResponseData.memberData; ////Kojashree pmd 19Dec : Removed deeply nested if-else
                        if(wrapIEESResponseData.matchResult==0){
                            addressMap.put('AddressLine1','');
                            addressMap.put('AddressLine2','');
                            addressMap.put('AddressLine3','');
                            hasError=true;
                            
                        }else if(clientData != null){
                            //clientData=wrapIEESResponseData.memberData;
                          if(clientData.programData!=null && clientData.programData.programs!=null){
                            for (Re_ClientViewWrapper.Programs obj : clientData.programData.programs){
                                EnrolledProgramsWrapper objEnrollProg = new EnrolledProgramsWrapper(obj.assistanceType,obj.eligibilityBeginDate,obj.renewalDate);
                                lstWrapprEnrollProgs.add(objEnrollProg); 
                            }
                          }

                            addressMap.put('AddressLine1',clientData.addressData.addressLine1);
                            addressMap.put('AddressLine2',clientData.addressData.addressLine2);
                            addressMap.put('AddressLine3',(!String.isEmpty(clientData.addressData.city)?clientData.addressData.city+', ':'')+(!String.isEmpty(clientData.addressData.state)?clientData.addressData.state+' ':'')+(!String.isEmpty(clientData.addressData.zipCode)?clientData.addressData.zipCode:''));
                        }//Kojashree pmd 19Dec : Removed deeply nested if-else
                        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyieesdata1= (wrapIEESResponseData != null && wrapIEESResponseData.houseHoldMembersData != null && wrapIEESResponseData.houseHoldMembersData.houseHoldMembers!= null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                        switch on (switchCaseKeyieesdata1) {
                            when SWITCH_SUCCESS {                                
                                for (Re_ClientViewWrapper.HouseholdComposition obj : wrapIEESResponseData.houseHoldMembersData.houseHoldMembers ){
                                    HouseholdCompositionWrapper objHHComposition = new HouseholdCompositionWrapper(obj.firstName+' '+obj.lastName ,String.valueof(Integer.valueof((obj.dob.daysBetween(Date.Today()))/365)),obj.relationship);
                                    lstWrapprHouseholdComp.add(objHHComposition);
                                } 
                            }
                        }//Kojashree pmd 19Dec : Removed deeply nested if-else
                        }
                        when SWITCH_FAILURE {  
                            REIntegrationEndpoints__c oIntEndpoints = REIntegrationEndpoints__c.getValues('IEESClientDetails');
                            String sEndpoint = oIntEndpoints.Endpoint_URI__c;
                            String sHttpMethod = oIntEndpoints.Http_Method_Type__c;
                            addressMap.put('AddressLine1','');
                            addressMap.put('AddressLine2','');
                            addressMap.put('AddressLine3','');
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,sEndpoint,'Re_ClientDetailsCtrl','execute','Callout to Case Detail Failed',sHttpMethod,
                            String.valueof(mapInputData)!=null?JSON.serialize(mapInputData):'Individual ID missing',wrapIEESResponseData.errorData.errorCode,wrapIEESResponseData.errorData.errorDescription,0,false);
                        }
                    }
                    }
                    when SWITCH_FAILURE{
                        hasError=true;
                        addressMap.put('AddressLine1','');
                        addressMap.put('AddressLine2','');
                        addressMap.put('AddressLine3','');
                    }
                }
            }
            mapResponse.put('HHComp',JSON.serialize(lstWrapprHouseholdComp));  
            mapResponse.put('EnrollPrgs',JSON.serialize(lstWrapprEnrollProgs)); 
            
            // Code to get the Table Data from IEES - END - Suyash Singhal 
            ClientsDetailsWrapper summaryWrapper=new ClientsDetailsWrapper(contactDetails.Id,contactDetails.Name,
                                                                           JSON.serialize(contactDetails.MailingAddress),contactDetails.Email,
                                                                           contactDetails.PreferredCommunicationMethod__c,contactDetails.Phone,contactDetails.Age__c
                                                                          );
            summaryWrapper.Gender=contactDetails.Gender__c;
            summaryWrapper.DOB=String.valueof(contactDetails.BirthDate);
            if(clientData != null && !hasError){
                summaryWrapper.AddressType=clientData.addressData.addressType;
                mapResponse.put('clientUniqueId',clientData.individualId);
            }else{
                summaryWrapper.AddressType='';
                mapResponse.put('clientUniqueId','');
            }
            //Quering User Photo
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnClientUser;
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnClientUser;
            User objUserdata = new User();
            mapQueryParameters = new Map<String,String>();
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            String sUserQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.userobjectName, sFieldsToQueryOnUser, mapQueryParameters);
            List<User> userList=new List<User>();
            userList=Database.query(sUserQuery);
            summaryWrapper.userDetails = userList.isEmpty()?null:userList[0];
            
            //Fetch Referrals for a client
            summaryWrapper.referralCount=fetchReferralCount(clientId);
            
            //Fetch Notes foe client
            RE_CreateLightningServerResponse notesresponse=RE_NotesHelper.getNotes(clientId, Label.maxsoqlquerylimit,'1');
            
            if(notesresponse.isSuccessful){
                summaryWrapper.notesList=notesresponse.objectData.get('records');
            }
            //Check if client is added as favorite
            summaryWrapper.isFavorite = checkClientFavorite(clientId);
            //Fetch Risk Factors for client
            List<SDOH__c> riskfactors= new List<SDOH__c>();
            riskfactors=fetchRiskFactors(clientId);
            //Fetch all SDOH category picklist values  ***Arun***
            List<String> listSDOHCategoryValues=new List<String>();
            listSDOHCategoryValues=getSDOHAllPicklistValues();
            mapResponse.put('riskScoresSetting',RE_SDOHScores__c.getAll().values()); 
            mapResponse.put('details',summaryWrapper); 
            mapResponse.put('riskFactors',riskfactors); 
            mapResponse.put('IEESAddress',addressMap);
            mapResponse.put('listSDOHCategoryValues',listSDOHCategoryValues);
            if(sRoleName!=null && (sRoleName.contains(RE_GlobalConstants.CASE_WORKER_SUPERVISOR)||
               sRoleName.contains(RE_GlobalConstants.CASE_WORKER))){
                bIsAgencyUser = true;
                hasActiveConsent = true;
                hasConsentToView = true;
            }
            mapResponse.put('hasActiveConsent',hasActiveConsent);
            mapResponse.put('hasConsentToView', hasConsentToView);
            mapResponse.put('bIsAgencyUser', bIsAgencyUser);
            }
            bSuccess = true; 
            
        }catch(Exception e) {
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ClientDetailsCtrl','fetchClientDetails',e.getMessage() +' ' +e.getLineNumber(), true);
        } 
        
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /**************************************************************************************
* @author       Payal Dubela
* @date         11/06/2019
* @methodname   createNote()
* @description  This methods is used to create note for client
* @param        String noteTitle String noteDescription String clientId
* @return       RE_CreateLightningServerResponse 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse createNote(String strNoteTitle,String strNoteDescription,String strClientId) {
        
        String noteTitle = String.escapeSingleQuotes(strNoteTitle);
        String noteDescription = String.escapeSingleQuotes(strNoteDescription);
        String notesTitle = noteTitle.replace('\\', '');
        String notesDescription = noteDescription.replace('\\', '');
        String clientId = String.escapeSingleQuotes(strClientId);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try {            
            ContentNote objContentNote = new ContentNote();
            //String body = '<p>' + noteDescription.escapeHtml4() + '</p>';
            String body = RE_GlobalConstants.NOTES_BODY_Tag + notesDescription.escapeHtml4() + RE_GlobalConstants.NOTES_BODY_END_Tag;
            objContentNote.Content = Blob.valueof(body);
            objContentNote.Title = notesTitle; 
            Database.SaveResult[] dbSaveResult = RE_SharingByPassCtrl.insertContentDocument(ContentNote.sObjectType,objContentNote);
            RE_SharingByPassCtrl.markNotesPublicOrPrivate(dbSaveResult, false);
            
            ContentDocumentLink objContentDocLink = new ContentDocumentLink();
            objContentDocLink.LinkedEntityId = clientId;
            objContentDocLink.ContentDocumentId = objContentNote.Id;
            objContentDocLink.ShareType = RE_GlobalConstants.strNotesShareType;
            objContentDocLink.Visibility = RE_GlobalConstants.strNotesVisibility;            
            RE_DataAccessChecker.insertObject(ContentDocumentLink.sObjectType, objContentDocLink);
            
            bSuccess = true;
        } catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl', 'createNote', e.getMessage(), true); }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /**************************************************************************************
* @author       Payal Dubela
* @date         13/06/2019
* @methodname   refreshNotes()
* @description  This methods is used to refresh note for client
* @param        String  clientId
* @return       RE_CreateLightningServerResponse 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse refreshNotes(String strClientId) {
        
        GeneralUtility.isAuthenticatedUser();
        // RE_CreateLightningServerResponse getNotesResponse=RE_NotesCtrl.getNotes(clientId,Label.maxsoqlquerylimit,'1');
        // return getNotesResponse;
        RE_CreateLightningServerResponse objResponse;
        try{
            String clientId = String.escapeSingleQuotes(strClientId);
            objResponse=RE_NotesHelper.getNotes(clientId, Label.maxsoqlquerylimit,'1');
        }
        catch(Exception e){LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl', 'refreshNotes', e.getMessage(), true);}
        return objResponse;
    }
    /**************************************************************************************
* @author       Payal Dubela
* @date         13/06/2019
* @methodname   checkNoteEditPermission
* @description  This methods is used to check edit permission for note
* @param        String  noteid
* @return       Boolean 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse checkNoteEditPermission(String strNoteId) {
        
        GeneralUtility.isAuthenticatedUser();
        Id userId = UserInfo.getuserId();
        Boolean isEditable;
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try {
            String noteId = String.escapeSingleQuotes(strNoteId);
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
        }catch(Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl', 'checkNoteEditPermission', e.getMessage(), true);} 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /**************************************************************************************
* @author       Payal Dubela
* @date         12/06/2019
* @methodname   updateNote
* @description  This methods is used to update notes on edit
* @param        String noteId String title String description
* @return       RE_CreateLightningServerResponse 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateNote(String strNoteId,String strTitle,String strDescription){
        
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try {
            String noteId = String.escapeSingleQuotes(strNoteId);
            String title = String.escapeSingleQuotes(strTitle);
            String description = String.escapeSingleQuotes(strDescription);
            String noteTitle = title.replace('\\', '');
            String noteDescription = description.replace('\\', '');
            ContentNote objContentNote = new ContentNote();
            objContentNote.Id= noteId;
            objContentNote.Title=noteTitle;
            //String body = '<p>' + description.escapeHtml4() + '</p>';
            String body = RE_GlobalConstants.NOTES_BODY_Tag + noteDescription.escapeHtml4()  + RE_GlobalConstants.NOTES_BODY_END_Tag;
            objContentNote.Content = Blob.valueof(body);
            RE_DataAccessChecker.updateSetUpObject(ContentNote.sObjectType,objContentNote);
            bSuccess = true;
        } catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl', 'updateNote', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
        
    }
    /**************************************************************************************
* @author       Payal Dubela
* @date         12/06/2019
* @methodname   checkConsent
* @description  This methods is used to check consent of client
* @param        String clientId
* @return       Boolean 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse checkConsent(String strClientId){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        //Boolean bIsAssister = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        RE_CreateLightningServerResponse response;
        try{
            //One View Not working for IEES Individuals - Payal Dubela-04/09
            if(String.isNotBlank(strClientId)){
            String clientId = String.escapeSingleQuotes(strClientId);
            response=checkConsentWithStatus(strClientId,RE_GlobalConstants.CONSENT_STATUS_ACTIVE);
            if(response.isSuccessful){
                bSuccess=response.isSuccessful;
                mapResponse.put('hasConsentToView',response.objectData.get('hasActiveConsent'));
                mapResponse.put('objConsent', response.objectData.get('objConsent'));  
            }else{
                bSuccess=false;
                errorMap=response.mapErrorInfo;
            }
           }else{
             bSuccess=true;
           }
        }catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl', 'updateNote', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/24/2019
* @methodname   checkConsentWithStatus()
* @description  This method checks Consent of Client based on Status
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse checkConsentWithStatus(String strClientId,String strconsentObjStatus){
        GeneralUtility.isAuthenticatedUser();
        String clientId=(!String.isBlank(strClientId))?String.escapeSingleQuotes(strClientId):'';
        String consentObjStatus=(!String.isBlank(strconsentObjStatus))?String.escapeSingleQuotes(strconsentObjStatus):'';
        Boolean bSuccess = false;
        Boolean bIsAssister = false;
        Boolean bIsAgencyUser = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sQuery;
        String sWhereClause;
        Boolean hasConsentToView=false;
        Boolean hasActiveConsent=false;
        String consentStatus=RE_GlobalConstants.CONSENT_STATUS_ACTIVE;
        String sOrganization=RE_GlobalConstants.ORGANIZATION;
        String sAssister=RE_GlobalConstants.ASSISTER;
        List<Consent__c> consentList=new List<Consent__c>();
        Consent__c objConsent = new Consent__c();
        //RE Security Changes -- Payal Dubela
        String loggedInUserAccountId=GeneralUtility.getLoggedInAccountId();
        String loggedInUserContactId=GeneralUtility.getLoggedInUserContactId();
        try {
            
            //Check that logged-In User is assister or not
            ID userid=UserInfo.getUserId();
            String sProfile = GeneralUtility.getLoggedInUserSelectedRole();
            if(sProfile!=null && sProfile.contains(RE_GlobalConstants.RE_ASSISTER_ROLE)){
                    bIsAssister=true;
                }
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnClientConsent;
            String sOrderBy = RE_DataBaseQueryFields.sCreatedDateDESC;
            if(bIsAssister){
                sWhereClause=RE_DataBaseQueryFields.sWhereClauseOnClientConsentForAssister;  
            }else{
                sWhereClause=RE_DataBaseQueryFields.sWhereClauseOnClientConsent;
            }
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderBy);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.consentobjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    consentList = Database.query(sQuery);
                    if((!consentList.isEmpty())&& consentList.size()>0){
                        hasActiveConsent=true;
                    }
                    if(sProfile!=null && (sProfile.contains(RE_GlobalConstants.CASE_WORKER_SUPERVISOR) || sProfile.contains(RE_GlobalConstants.CASE_WORKER)))
                    {
                        bIsAgencyUser = true;
                        hasActiveConsent = true;
                        hasConsentToView=true;
                    }
                    else{
                        consentStatus = consentObjStatus;
                        consentList = Database.query(sQuery);
                        if((!consentList.isEmpty())&& consentList.size()>0){
                            objConsent = consentList[0];
                            hasConsentToView=true;
                        }
                    }
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchClientDetails','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            bSuccess=true;
            mapResponse.put('hasActiveConsent',hasActiveConsent);
            mapResponse.put('objConsent', objConsent);  
            mapResponse.put('hasConsentToView', hasConsentToView);
        }catch (Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl', 'updateNote', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
        
    }
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         07/29/2019
* @methodname   sendEmail()
* @description  This methods is used to create central hub record with email details to send email from one-view
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse sendEmail(Map<String,Object> sendEmailWrapper){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        String objComUrl = Community_URL_Settings__c.getInstance().URL__c;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try{
            String strEmailTemplateBody = Label.RE_Hello+' '+sendEmailWrapper.get('clientName')+',<p>'+sendEmailWrapper.get('message');            
            strEmailTemplateBody+= Label.RE_Oneview_Send_Email_Footer+': '+'<a href='+objComUrl+'>'+ objComUrl+'</a>'+'.'+'<br>';
            strEmailTemplateBody+= Label.RE_doNotReplyMessage + ' ' + Label.RE_PIIMessage + '<br>'+Label.RE_SecurityMessage;
            String sUserName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
            sUserName.replace('null','');
            sUserName.trim();
            
            List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
            CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
            Database.SaveResult[] srCommunicationNubList;
            
            objCommunicationNub.EmailSubject__c = String.format(Label.RE_SendEmailOneViewSubject, new List<String>{ sUserName });
            objCommunicationNub.TemplateBody__c = strEmailTemplateBody;
            //Added By Kojashree
        	objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                       
            objCommunicationNub.ToEmail__c = String.valueOf(sendEmailWrapper.get('clientEmail'));
            
            objCommunicationNub.TriggeredRecordId__c = String.valueOf(sendEmailWrapper.get('clientId'));
            
            objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
            objCommunicationNub.TemplateName__c= Label.RE_OneViewClientEmail ;
            
            lstCommunicationNubInsert.add(objCommunicationNub); 
            
            if(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){                
                srCommunicationNubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                bSuccess = true;
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_ShareEmailCtrl.class.getName(), 'shareResourceDetailsViaEmail','No Access on Framework_Log__c Object',true);
            }
        }catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ClientDetailsCtrl.class.getName(), 'sendEmail', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /**************************************************************************************
* @author       Payal Dubela
* @date         18/08/2019
* @methodname   fetchRiskFactors
* @description  This methods is used to query SDOH per categories
* @param        String clientId
* @return       Boolean 
******************************************************************************************/
    public static List<SDOH__c> fetchRiskFactors(String clientId){
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        List<SDOH__c> riskFactorsList= new List<SDOH__c>();
        String sQuery;
        String sFieldsApiName;
        try {
            sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnClientSDOH;
            String sWhereClause=RE_DataBaseQueryFields.sWhereClauseOnSDOHOneView;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sdohObjName, sFieldsApiName, mapQueryParameters);
                
            if(mapResponseData.get(true) != null){
                sQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sdohObjName, RE_DataBaseQueryFields.sFieldsToQueryOnClientSDOHToLabel,mapQueryParameters);
                riskFactorsList = RE_SharingByPassCtrl.fetchRiskFactors(clientId, sQuery); 
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ClientDetailsCtrl','fetchRiskFactors','***FLS Violation***'+mapResponseData.get(false),true);
            }
        }catch(Exception e) 
        {
            errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchRiskFactors', e.getMessage(), true);
        } 
        return riskFactorsList;
    }
    
    /**************************************************************************************
* @author       Arun Garg
* @date         12/09/2019
* @methodname   fetchAssessmentRecords
* @description  This methods is used to fetch Assessment records of Assessment template record types
* @return       RE_CreateLightningServerResponse 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchAssessmentRecords(){
        GeneralUtility.isAuthenticatedUser();
        List<Assessment__c> lstAssessment ;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try{
                    Id assessmentRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sAssessmentObjectName, RE_GlobalConstants.sAssessmentDeveloperName);
                    String sFieldsToQueryOnAssessment = RE_DataBaseQueryFields.sFieldsToQueryOnAssessment;
                    
                    String sOrderby = RE_DataBaseQueryFields.sOrderbyAssessment;
                   
                    String sWhereClauseOnAssessment = RE_DataBaseQueryFields.sWhereClauseOnAssessment;
                    Map<String,String> mapAssessmentQueryParameters = new Map<String,String>();
                    mapAssessmentQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
                    mapAssessmentQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAssessment);
                    Map<Boolean,String> mapAssessmentQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sAssessmentObjectName, sFieldsToQueryOnAssessment, mapAssessmentQueryParameters);
                    String switchCaseKey = (mapAssessmentQueryResponse.get(true) != null) ? 'success' : 'failure'; 
                    switch on (switchCaseKey) {
                        when 'success' {
                            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sAssessmentObjectName, RE_DataBaseQueryFields.sFieldsToQueryOnAssessment, mapAssessmentQueryParameters);
                            lstAssessment = Database.query(sQuery); 
                            bSuccess = true;
                            mapResponse.put('assessmentRecords', lstAssessment);
                        }
                        when 'failure' {
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords','Some Fields doesn\'t have the required access :: '+mapAssessmentQueryResponse.get(false), true);
                        }
                    }
                }catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords', e.getMessage(), true);}
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }  
    /**************************************************************************************
* @author       Arun Garg
* @date         12/09/2019
* @methodname   createUserAssessmentRecords
* @description  This methods is used to save Assessment records of user template record types
* @param        String residentId,String assessmentId
* @return       RE_CreateLightningServerResponse 
******************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchAssessmentResponses(String strResidentId){
        GeneralUtility.isAuthenticatedUser();
        List<Assessment__c> lstAssessmentResponse ;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try{
                    String residentId = String.escapeSingleQuotes(strResidentId);
                    Id userAssessmentRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sAssessmentObjectName, RE_GlobalConstants.sAssessmentUserDeveloperName);
                    String sFieldsToQueryOnAssessment = RE_DataBaseQueryFields.sFieldsToQueryOnUserRecordType;
                    String sWhereClauseOnAssessment = RE_DataBaseQueryFields.sWhereClauseOnUserRecordType;
                    Map<String,String> mapAssessmentQueryParameters = new Map<String,String>();
                    mapAssessmentQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAssessment);
                    Map<Boolean,String> mapAssessmentQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sAssessmentObjectName, sFieldsToQueryOnAssessment, mapAssessmentQueryParameters);
                    String switchCaseKey = (mapAssessmentQueryResponse.get(true) != null) ? 'success' : 'failure'; 
                    switch on (switchCaseKey) {
                        when 'success' {
                            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sAssessmentObjectName, sFieldsToQueryOnAssessment, mapAssessmentQueryParameters);
                            lstAssessmentResponse = Database.query(sQuery); 
                        }
                        when 'failure' {
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords','Some Fields doesn\'t have the required access :: '+mapAssessmentQueryResponse.get(false), true);
                        }
                    }
                    Id conid=GeneralUtility.getLoggedInUserContactId();
                    List<AssessmentWrapper> lstAssessmentWrapper =new List<AssessmentWrapper>();
                    for (Assessment__c assRes : lstAssessmentResponse){                        
                        AssessmentWrapper objAssRes = new AssessmentWrapper(assRes.createdDate.Date(),assRes.AssessmentTemplate__r.AssessmentTitle__c,assRes.Partner__r.name,assRes.Id,conid);
                        lstAssessmentWrapper.add(objAssRes);
                    }
                    bSuccess = true;    
                    mapResponse.put('assessmentResponseRecords',lstAssessmentWrapper);
                }
        catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentResponses', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }
    
    /********************************************************************************************
* @author       Payal dubela
* @date         02/07/2019
* @methodname   getReferralCount()
* @description  This methods is used to get the referral count for different status
* @param        clientId           (String)   : contact Id
* @return       Map<String,Integer>  
**********************************************************************************************/  
    public static Map<String,Integer> fetchReferralCount(String clientId){
        Map<String, String> mapQueryParameters = new Map<String, String>();
        String sQuery;
        Map<Boolean, String> mapResponseData = new Map<Boolean,String>();
        List<Referral__c> referralsByClient=new List<Referral__c>();
        Map<String,Integer> referralCountByStatus=new Map<String,Integer>{'New' => 0, 'InProgress' => 0,'Closed'=> 0};
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnClientReferral;
        String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnClientReferral;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strReferralObjectName, sFieldsApiName, mapQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sQuery =  mapResponseData.get(true);
                referralsByClient=RE_SharingByPassCtrl.fetchReferralCount(sQuery,clientId);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchReferralCount','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        for(Referral__c ref:referralsByClient){
            String switchCaseKey1=ref.Status__c;
            switch on (switchCaseKey1) {
                when 'New' {    
                    referralCountByStatus.put('New',(referralCountByStatus.get('New'))+1);
                }   
                when 'In Progress - Org in System' ,'In Progress - Org Not in System'{
                    referralCountByStatus.put('InProgress',(referralCountByStatus.get('InProgress'))+1);
                }
                when 'Closed' { 
                    referralCountByStatus.put('Closed',(referralCountByStatus.get('Closed'))+1);
                }
            }
        }
        return referralCountByStatus;
        
    }
    /**************************************************************************************
* @author       Arun Garg
* @date         25/10/2019
* @methodname   getSDOHAllPicklistValues
* @description  This methods is used to get all the category picklist values
* @param       
* @return       List of string 
******************************************************************************************/
    public static List<String> getSDOHAllPicklistValues(){
        List<String> listCatgoryPicklistValues=new List<String>();
        Map<String, Object> errorMap    = new Map<String, Object>();
        try {
            Schema.DescribeFieldResult sdoh = SDOH__c.Category__c.getDescribe();
            Schema.sObjectField sdohField = sdoh.getSObjectField();
            List<PicklistEntry> entries = sdohField.getDescribe().getPicklistValues();
            for(PicklistEntry entry:entries){
                listCatgoryPicklistValues.add(entry.getLabel());
            }
        }catch(Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','getSDOHAllPicklistValues', e.getMessage(), true);} 
        return listCatgoryPicklistValues;
    }
        /********************************************************************************************
    * @author       Payal Dubela
    * @date         11/18/2019
    * @methodname   createContactForIEESData()
    * @description  Method to create Contact for IEESData
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/  
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse createContactForIEESData(String IEESData){
        GeneralUtility.isAuthenticatedUser();
            Id contactId;
            Boolean bSuccess = false;
            Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
            try {
            RE_ClientsHelper.DataTableWrapper clientData=(RE_ClientsHelper.DataTableWrapper)JSON.deserialize(IEESData,RE_ClientsHelper.DataTableWrapper.class);
            contactId=RE_CreateCitizenHelper.createContact(Integer.valueof(clientData.IEESId),clientData);
            mapResponse.put('clientId',contactId);
            bSuccess=true;
            }catch(Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','createContact', e.getMessage(), true);} 
            return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
        }
    /********************************************************************************************
    * @author       Payal Dubela
    * @date         12/04/2019
    * @methodname   getSDOHPickListValues()
    * @description  get sdoh picklist values
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/  
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse getSDOHValues(){
        GeneralUtility.isAuthenticatedUser();
         Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
         try {
            List<String> listSDOHCategoryValues=new List<String>();
            listSDOHCategoryValues=getSDOHAllPicklistValues();
            mapResponse.put('listSDOHCategoryValues',listSDOHCategoryValues);
            bSuccess = true; 

         }catch(Exception e) {errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','getsdohvalues', e.getMessage(), true); } 
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);

    }
    /********************************************************************************************
* @author       Nandita Bapaye
* @date         03/26/2020
* @methodname   createClientFavourite()
* @description  insert select record as client favorite
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/  
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse createClientFavourite(String clientId){
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse sFavResponse; 
        String strClientId= (String.isNotBlank(clientId))?String.escapeSingleQuotes(clientId):'';
        sFavResponse = RE_CreateFavCtrl.createFavoriteClient(strClientId);
        return sFavResponse;
    }
    
     @AuraEnabled
    public static RE_CreateLightningServerResponse removeFavoriteClient(String clientId){
        GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse sFavResponse; 
        String strClientId= (String.isNotBlank(clientId))?String.escapeSingleQuotes(clientId):'';
        sFavResponse = RE_CreateFavCtrl.removeFavoriteClient(strClientId);
        return sFavResponse;
    }
    
    public static Boolean checkClientFavorite(String strClientId){
        String sClientId= (String.isNotBlank(strClientId))?String.escapeSingleQuotes(strClientId):'';
        Boolean isFavorite = false;
        List<Favorite__c> lstFav = new List<Favorite__c>();
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        String sQuery;
        if (String.isNotBlank(sClientId)) { 
            String sContactId = GeneralUtility.getLoggedInUserContactId();
            String sFieldsApiName = RE_DataBaseQueryFields.FIELDS_CREATE_FAVORITES;
            String sWhereClause = RE_DataBaseQueryFields.WHERE_CLAUSE_CREATE_FAVORITE_CLIENTS;
            Id sFavClientRecordTypeId= GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sFavoriteObjectName, RE_GlobalConstants.sFavoriteDeveloperName);
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sFavoriteObjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    LstFav = RE_SharingByPassCtrl.getFavoriteClients(sQuery,sClientId,sContactId,sFavClientRecordTypeId);
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','checkClientFavorite','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            if (!lstFav.isEmpty()) {
                isFavorite = true;
            }
        }
        
        return isFavorite;
    }
    
    //Wrapper class to get the notes
    
    public class ClientsDetailsWrapper {
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String clientName;
        @AuraEnabled       
        public String clientAddress;
        @AuraEnabled 
        public String clientEmail;
        @AuraEnabled 
        public String clientPreferredCommunication;
        @AuraEnabled 
        public String  clientPhone ;
        @AuraEnabled 
        public Decimal clientAge ;
        @AuraEnabled 
        public Object notesList;
        @AuraEnabled 
        public User  userDetails;
        @AuraEnabled
        public Map<String,Integer> referralCount;
        @AuraEnabled public String clientOrganization;
        @AuraEnabled public String AddressType;
        @AuraEnabled public String Gender;
        @AuraEnabled public String DOB; 
         @AuraEnabled public Boolean isFavorite;
        public ClientsDetailsWrapper(String clientId,String clientName,String clientAddress,
                                     String clientEmail,String clientPreferredCommunication,
                                     String clientPhone, Decimal clientAge){
                                         this.clientId=clientId;
                                         this.clientName=clientName;
                                         this.clientAddress=clientAddress;
                                         this.clientEmail=clientEmail;
                                         this.clientPhone=clientPhone;
                                         this.clientAge = clientAge;
                                         this.clientPreferredCommunication=clientPreferredCommunication;                               
                                         
                                     }
    }
    
    public class HouseholdCompositionWrapper {
        public String HHCUniqueId;
        public String ClientName;
        public String Age;
        public String Relationship;
        
        public HouseholdCompositionWrapper(String ClientName,String Age,String Relationship){
            // this.HHCUniqueId = HHCUniqueId;
            if(Integer.valueOf(Age) < 18){
              this.ClientName = '(Child)';  
            }else{
               this.ClientName = ClientName; 
            }
            this.Age = Age;
            this.Relationship=Relationship;
        }
    }
    
    public class EnrolledProgramsWrapper {
        public String ProgramFullName;
        public String StartDate;
        public String RenewalDate;
        
        public EnrolledProgramsWrapper(String ProgramFullName,String StartDate,String RenewalDate){
            this.ProgramFullName = ProgramFullName;
            this.StartDate = StartDate;
            this.RenewalDate = RenewalDate;
        }
    }
    public class AssessmentWrapper {
        @AuraEnabled public Date assessmentSubmitDate;
        @AuraEnabled public String assessmentTitle;
        @AuraEnabled public String assessmentTakenBy;
        @AuraEnabled public String assessmentId;
        @AuraEnabled public String partnerId;
        
        public AssessmentWrapper(Date AssessmentSubmitDate,String AssessmentTitle,String AssessmentTakenBy,String assessmentId,String partnerId){
            this.AssessmentSubmitDate = AssessmentSubmitDate;
            this.AssessmentTitle = AssessmentTitle;
            this.AssessmentTakenBy = AssessmentTakenBy;
            this.assessmentId= assessmentId;
            this.partnerId= partnerId;
        }
    }
    
    
}