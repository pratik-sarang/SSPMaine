/**
* Class Name    : RE_RequestConsentModalCtrl
* Owner         : Abhijeet
* Created Date  : 07/18/2019
* Description   : Controller class for Request Consent
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/18/2019  Abhijeet        Initial Version
*  12/06/2019  Megha           Removed the incorrect email part for consent email agreement - Bug(339713)
*  12/10/2019  Megha Mittal    Added the changes update email text for verbal consent- Bug(339713)
**/
public with sharing class RE_RequestConsentModalCtrl {
    
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/18/2019
* @methodname   fetchClientDetails()
* @description  Method to fetch CLient Details
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchClientDetails(String strClientId){
        
        GeneralUtility.isAuthenticatedUser();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        String sQuery;
        Boolean bSuccess = false;
        Contact objContact =new Contact();
        try{
            String clientId = String.escapeSingleQuotes(strClientId);
          //RE_Release 1.1 – Error Log Fix - Payal Dubela
          if(clientId!=null && !String.isEmpty(clientId)){
            String sFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnClientContact;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnClientContact;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strSobjectName, sFieldsApiName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    sQuery = sQuery.replace('Name','Name, Recordtype.DeveloperName,Account.Applicable_Roles__c');
                    objContact = RE_SharingByPassCtrl.getContactDetails(sQuery,clientId); 
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchClientDetails','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            mapResponse.put('objContact', objContact);
            RE_CreateLightningServerResponse resp = RE_ClientDetailsCtrl.checkConsentWithStatus(clientId,'Pending');
            mapResponse.put('objConsent', resp.objectData.get('objConsent'));
            mapResponse.put('hasActiveConsent', resp.objectData.get('hasActiveConsent'));
            mapResponse.put('hasConsentToView', resp.objectData.get('hasConsentToView'));
            /* [Suresh] Request Consnet Requirement 357632 - Starts*/
            boolean hideSendTextBtn = false;
            if((objContact.Recordtype.DeveloperName == RE_GlobalConstants.strCitizenRecordTypeName ||
                (objContact.Recordtype.DeveloperName == RE_GlobalConstants.strNonCitizenContactDevName
                 && objContact.Account.Applicable_Roles__c!=null && objContact.Account.Applicable_Roles__c.contains(RE_GlobalConstants.strCitizenAppRole)))
               && objContact.ConsentToTexts__c == false && objContact.OptOutInfoSharing__c == false){
                hideSendTextBtn=true;
            }
            mapResponse.put('hideSendTextBtn', hideSendTextBtn);
            /* [Suresh] Request Consnet Requirement 357632 - Ends*/
            bSuccess = true;
          }
        }
        catch(Exception e){
            bSuccess = false;
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','fetchClientDetails','Error Occured:: '+ e.getMessage(), true); 
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/18/2019
* @methodname   sendConsentForText()
* @description  Method to Send Request for Consent in a Text message to Client
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/  
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse sendConsentForText(Contact objContact,String strConsentId){
        
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> ObjectDetailsWrapper = new Map<String, Object>();
        Map<String,String> mapInputWrapper = new Map<String,String>();
        Consent__c objConsent;
		Boolean prefMethodBoolean;
        String consType = 'Text';

        try{
            String consentId = strConsentId;
            if(!String.isEmpty(strConsentId)){
                consentId = String.escapeSingleQuotes(strConsentId);
            }
            //Force Reviewer Changes - Payal Dubela - 08/28
            objConsent=(consentId!=null)?fetchConsentRecord(consentId):((String.isNotBlank(objContact.Phone))?objConsent = insertConsent('Text',objContact,'Pending',''):null);

            //Added by Anuj : added Object and field accessibility check
            Id conId;
            if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType) && RE_DataAccessChecker.isSafeField('ContactId', 'User')){
                 conId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() AND Id != null].ContactId;
            }
            
            //Nupoor: added object and field accessibility checks
            String phone;
            if(RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && RE_DataAccessChecker.isSafeField('Phone', 'Contact') && conId!=null )
            {
                phone = [SELECT Phone FROM Contact WHERE Id =: conId AND Id != null].Phone;
            }
            String sPhone = RE_GlobalConstants.sPhoneInitialization+phone;
            String sUserName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
            sUserName.replace('null','');
            if(sUserName.length()>26){
                sUserName =sUserName.substring(0, 25);
            }
            String toPhone = RE_GlobalConstants.sPhoneInitialization+objContact.Phone;
            mapInputWrapper.put('yourName',sUserName);
            mapInputWrapper.put('yourEmail',UserInfo.getUserEmail());
            mapInputWrapper.put('yourPhone',sPhone);
            mapInputWrapper.put('toEmail',objContact.Email);
            mapInputWrapper.put('toPhone',toPhone);
            
            ObjectDetailsWrapper.put('resourceId',objContact.Id);
            ObjectDetailsWrapper.put('sResourceName',objContact.Name);
            String surveyLink;

            if(String.isEmpty(objContact.PreferredCommunicationMethod__c)){
                prefMethodBoolean = true;
            }else{
                prefMethodBoolean = false;
            }
            
                if(test.isrunningTest()){
                    surveyLink = TestDataFactory.testSurveyLink;
                }
                else{
                    String surveyInvitationRecId = RE_InsertSurveyInvitationCtrl.saveSurveyInvitation('RE_Consent_Survey_1',objConsent.Id,'Consent',true,true);
                    String communityBaseUrl = Community_URL_Settings__c.getInstance().URL__c;
                    surveyLink =  communityBaseUrl+'/s/survey-page?invitationId='+surveyInvitationRecId+'&prefMethod='+prefMethodBoolean+'&consType='+consType;
                    
            }
                    
            
        if(String.isNotBlank(objContact.Phone)){
           // RE_CreateLightningServerResponse resp = RE_ShareEmailCtrl.triggerSmsFramework(strPhoneTemplateBody,mapInputWrapper,ObjectDetailsWrapper);
           RE_MessageUtility.consentSMS( surveylink, objContact.Id, objContact.Name, sUserName,  sPhone,  objContact.Email,  toPhone );
            // 
            //if(resp.isSuccessful==true){
                List<Consent__c> lstConsent = new List<Consent__c>();
                if(objConsent != null){
                    lstConsent.add(objConsent);
                }
                
                RE_CreateLightningServerResponse consentResp = updateConsent(lstConsent,'Text',objContact);
                if(consentResp.isSuccessful == true){
                    bSuccess = true;
                }
        }
            bSuccess = true;
        
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_RequestConsentModalCtrl.class.getName(), 'sendConsentText', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/18/2019
* @methodname   sendConsentForEmail()
* @description  Method to Send Request for Consent in an Email to Client
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/    
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse sendConsentForEmail(Contact objContact,String strConsentId){
        
        String consentId;
        if(!String.isEmpty(strConsentId)){
            consentId = String.escapeSingleQuotes(strConsentId);
        }
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String,String> mapInputWrapper = new Map<String,String>();
        Map<String, Object> ObjectDetailsWrapper = new Map<String, Object>();
        Consent__c objConsent;
        Boolean prefMethodBoolean = false;
        String consType;
        
        try{
            //Force Reviewer Changes - Payal Dubela - 08/28
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyEmailSetting = (EmailSetting__c.getInstance('Request to access resident profile').Is_on__c && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyEmailSetting) {
             when SWITCH_SUCCESS {  
                if(consentId!=null){ 
                    objConsent = fetchConsentRecord(consentId);
                }
                else{
                    objConsent = insertConsent('Email',objContact,'Pending',objContact.Email);
                }
                //Nupoor: added object and field accessibility
                Consent__c objConsentDetails = new Consent__c();
                if(RE_DataAccessChecker.isAllowedToAccess(Consent__c.sObjectType) && RE_DataAccessChecker.isSafeField('Organization__c', 'Consent__c')  
                  && RE_DataAccessChecker.isSafeField('Assister__c', 'Consent__c') && RE_DataAccessChecker.isSafeField('Name', 'Contact')
                  && RE_DataAccessChecker.isSafeField('Name', 'Account') && objConsent!=null){
                    objConsentDetails = [SELECT CreatedBy.Name,Organization__r.Name,Assister__r.Name FROM Consent__c WHERE Id=:objConsent.Id AND Id != null];
                }
                  
                //Added by Anuj : access check for Object and the field queried
                Id conId;
                if(RE_DataAccessChecker.isAllowedToAccess(User.sObjectType) && RE_DataAccessChecker.isSafeField('ContactId', 'User')){
                    conId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId() AND Id != null].ContactId;
                }
                //Id conId = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()].ContactId;
                //Nupoor: added object and field accessibility
                String phone;
                if(RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && RE_DataAccessChecker.isSafeField('Phone', 'Contact') && conId!=null){
                    phone = [SELECT Phone FROM Contact WHERE Id =: conId AND Id != null].Phone;
                }
                String sPhone = RE_GlobalConstants.sPhoneInitialization+phone;
                String sUserName = UserInfo.getFirstName()+' '+UserInfo.getLastName();
                sUserName.replace('null','');
                
                String toPhone = RE_GlobalConstants.sPhoneInitialization+objContact.Phone;
                mapInputWrapper.put('yourName',sUserName);
                mapInputWrapper.put('yourEmail',UserInfo.getUserEmail());
                mapInputWrapper.put('yourPhone',sPhone);
                mapInputWrapper.put('toEmail',objContact.Email);
                mapInputWrapper.put('toPhone',toPhone);
                
                ObjectDetailsWrapper.put('resourceId',objContact.Id);
                ObjectDetailsWrapper.put('sResourceName',objContact.Name); 
                String emailSubjectParameter ='';
                String emailBodyParameter2 ='';
                String emailBodyParameter3 ='';
                String emailBodyParameter4 ='';
                if(objConsent.ConsentLevel__c == 'Organization'){
                    emailSubjectParameter = RE_GlobalConstants.sCommunityPartner;
                    emailBodyParameter2 = objConsentDetails.Organization__r.Name;
                    emailBodyParameter3 = RE_GlobalConstants.sAtforEmail+objConsentDetails.Organization__r.Name;
                    emailBodyParameter4 = RE_GlobalConstants.sStaffforBody;
                }else{
                    emailSubjectParameter = RE_GlobalConstants.ASSISTER;
                    //emailBodyParameter2 = objConsentDetails.Assister__r.Name;
                    // Updated by Kojashree : Defect fix 391672
                    emailBodyParameter2 = objConsentDetails.Organization__r.Name;
                    emailBodyParameter3 ='';
                    emailBodyParameter4 =RE_GlobalConstants.sassisterforBody;
                }
                String surveyLink;
                   if(String.isEmpty(objContact.PreferredCommunicationMethod__c)){
                       prefMethodBoolean = true;
                   }else{
                       prefMethodBoolean = false;
                   }
                consType = RE_GlobalConstants.EmailOption;
                if(test.isrunningTest()){
                    surveyLink = TestDataFactory.testSurveyLink;
                }
                else{
                    String surveyInvitationRecId = RE_InsertSurveyInvitationCtrl.saveSurveyInvitation('RE_Consent_Survey_1',objConsent.Id,'Consent',true,true);
                    String communityBaseUrl = Community_URL_Settings__c.getInstance().URL__c;
                    surveyLink =  communityBaseUrl+'/s/survey-page?invitationId='+surveyInvitationRecId+'&prefMethod='+prefMethodBoolean+'&consType='+consType;
                    
                }
                                
                List<String> labelParameters = new List<String>();
                labelParameters.add(emailBodyParameter2);
                labelParameters.add(Label.System_Name);
                labelParameters.add(Label.System_Name);
                labelParameters.add(Label.System_Name);
                labelParameters.add(surveyLink);
                labelParameters.add(Label.System_Name);
                String strEmailTemplateBody = Label.RE_Hello+' '+objContact.Name+',';
                strEmailTemplateBody+='<br><br>'+String.format(Label.RE_RequestConsentSendEmailBody, labelParameters);
                strEmailTemplateBody+= Label.RE_doNotReplyMessage;
                strEmailTemplateBody+= '<br>'+Label.RE_SecurityMessage;
                //replace all the null with empty string in email body
                if(strEmailTemplateBody.contains('null')){
                    strEmailTemplateBody = strEmailTemplateBody.replace('null','');
                }
                
                List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
                Database.SaveResult[] srCentralHubList; 
                CommunicationLog__c objCentralHub = new CommunicationLog__c();
                
                objCentralHub.EmailSubject__c = String.format(Label.RE_SendConsentEmailSubject, new List<String>{ emailSubjectParameter });
                objCentralHub.TemplateBody__c = strEmailTemplateBody;
                objCentralHub.ToEmail__c = mapInputWrapper.get('toEmail');
                objCentralHub.FromEmail__c = mapInputWrapper.get('yourEmail');
                objCentralHub.TriggeredRecordId__c = String.valueOf(ObjectDetailsWrapper.get('resourceId'));
                objCentralHub.TriggeredRecordName__c= String.valueOf(ObjectDetailsWrapper.get('sResourceName'));
                objCentralHub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                objCentralHub.TemplateName__c= Label.RE_EmailTemplateNameRequestConsent;
                 //Added By Kojashree
        		objCentralHub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                            
                lstCommunicationNubInsert.add(objCentralHub);
                RE_GlobalConstants.SWITCH_CONSTANTS switchKeyonNubRecord =(!lstCommunicationNubInsert.isEmpty() && RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType()))? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                Switch on (switchKeyonNubRecord){
                    when SWITCH_SUCCESS {
                        srCentralHubList = RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);                  
                        List<Consent__c> lstConsent = new List<Consent__c>();                        
                        if(objConsent != null){                            
                            lstConsent.add(objConsent);
                        }
                        RE_CreateLightningServerResponse consentResp = updateConsent(lstConsent,'Email',objContact);
                        if(consentResp.isSuccessful == true){
                            bSuccess = true;
                        }
                    }
                    when SWITCH_FAILURE {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_ShareEmailCtrl.class.getName(), 'sendConsentForEmail','No Access on Framework_Log__c Object',true);    
                    }
                }
            }
          }            
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_RequestConsentModalCtrl.class.getName(), 'sendConsentForEmail', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/18/2019
* @methodname   updateConsent()
* @description  Method to Update or Insert a Consent Record for a Client
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/    
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateConsent(List<Consent__c> lstConsent,String modeCommunication,Contact clientDetail){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Boolean bIsAssister = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        try {
            Consent__c objConsent = new Consent__c();
            modeCommunication = String.escapeSingleQuotes(modeCommunication);
        /*String sOrganization=RE_GlobalConstants.ORGANIZATION;
        String sAssister=RE_GlobalConstants.ASSISTER;
        Consent__c objConsent = new Consent__c();
        String loggedInUserAccountId=GeneralUtility.getLoggedInUserAccountId();
        String loggedInUserContactId=GeneralUtility.getLoggedInUserContactId();
        try {
            //Check that logged-In User is assister or not
            ID userid=UserInfo.getUserId();
            String sFieldsToQueryOnperm = RE_DataBaseQueryFields.sFieldsToQueryOnperm;
            String sWhereClauseOnperm = RE_DataBaseQueryFields.sWhereClauseOnperm;
            String sPermissionSetQuery;
            
            Map<String,String> mappermQueryParameters = new Map<String,String>();
            mappermQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnperm);
            mappermQueryParameters.put(RE_GlobalConstants.sLimitKey,Label.maxsoqlquerylimit);
            sPermissionSetQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sPermissionSetObj, sFieldsToQueryOnperm, mappermQueryParameters); 
            
            List<PermissionSetAssignment> lstPermissionSet = Database.query(sPermissionSetQuery);
            for(PermissionSetAssignment pmset : lstPermissionSet){
                if(pmset.PermissionSet.Name==RE_GlobalConstants.ASSISTER_PERMISSIONSET_NAME){
                    bIsAssister=true;
                }
            }*/
           /* Profile sProfile = GeneralUtility.getLoggedInUserProfile();
            if(sProfile.Name == RE_GlobalConstants.RE_ASSISTER_PROFILE){
                bIsAssister=true;
            }*/
            if( lstConsent != null && lstConsent.size()>0 ){
                
                objConsent = lstConsent[0];
                if(modeCommunication == 'Text'){
                    objConsent.LastTextDate__c = system.now();
                    objConsent.ConsentProvidedBy__c = RE_GlobalConstants.CLAIM_ConsentProvidedText;
                }
                else if(modeCommunication == 'Email'){
                    objConsent.LastEmailDate__c = system.now();
                    objConsent.ConsentProvidedBy__c = RE_GlobalConstants.CLAIM_ConsentProvidedEmail;
                    objConsent.ClientEmailProvided__c = clientDetail.Email;
                }
                RE_DataAccessChecker.updateObject(Consent__c.getSObjectType(), objConsent);
            }
            bSuccess=true;
        }catch (Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl', 'updateNote', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse); 
    }
    
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/18/2019
* @methodname   insertConsent()
* @description  Method to Insert a Consent Record for a Client
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/    
    
    @AuraEnabled
    public static Consent__c insertConsent(String modeCommunication,Contact clientDetail,String sStatus,String Email){
        GeneralUtility.isAuthenticatedUser();
        Boolean bIsAssister = false;
        String sOrganization=RE_GlobalConstants.ORGANIZATION;
        String sAssister=RE_GlobalConstants.ASSISTER;
        //RE Security changes -- Payal Dubela
        String loggedInUserAccountId=GeneralUtility.getLoggedInAccountId();
        String loggedInUserContactId=GeneralUtility.getLoggedInUserContactId();
        Consent__c objConsentIns = new Consent__c();
        //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
        String strStatus=String.isNotBlank(sStatus)?String.escapeSingleQuotes(sStatus):sStatus;
        String sEmail=String.isNotBlank(Email)?String.escapeSingleQuotes(Email):Email;
        try {
            modeCommunication = String.escapeSingleQuotes(modeCommunication);
            //Check that logged-In User is assister or not
            /*ID userid=UserInfo.getUserId();
            String sFieldsToQueryOnperm = RE_DataBaseQueryFields.sFieldsToQueryOnperm;
            String sWhereClauseOnperm = RE_DataBaseQueryFields.sWhereClauseOnperm;
            String sPermissionSetQuery;
            List<PermissionSetAssignment> lstPermissionSet = new List<PermissionSetAssignment>();
            Map<String,String> mappermQueryParameters = new Map<String,String>();
            Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
            mappermQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnperm);
            mappermQueryParameters.put(RE_GlobalConstants.sLimitKey,Label.maxsoqlquerylimit);
            sPermissionSetQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sPermissionSetObj, sFieldsToQueryOnperm, mappermQueryParameters);
            lstPermissionSet = Database.query(sPermissionSetQuery);
            if(!lstPermissionSet.isEmpty()){
                for(PermissionSetAssignment pmset : lstPermissionSet){
                    if(pmset.PermissionSet.Name==RE_GlobalConstants.ASSISTER_PERMISSIONSET_NAME){
                        bIsAssister=true;
                    }
                }
            }*/
            //RE Security Changes -- Payal Dubela
            String sProfile = GeneralUtility.getLoggedInUserSelectedRole();
            if(sProfile!=null && sProfile.contains(RE_GlobalConstants.RE_ASSISTER_ROLE)){
                bIsAssister=true;
            }
            
           
             objConsentIns.Status__c = strStatus;
            objConsentIns.RequestDate__c = system.today();
            objConsentIns.Client__c = clientDetail.Id;
            objConsentIns.ClientEmailProvided__c=sEmail;
            objConsentIns.ClientPhoneProvided__c=clientDetail.Phone;
           /* User clientUser = [Select id from User where contactId =: clientDetail.Id];
            objConsentIns.ClientUser__c = clientUser.Id;*/
            if(modeCommunication == 'Text'){
                objConsentIns.LastTextDate__c = system.now();
                objConsentIns.ConsentProvidedBy__c = RE_GlobalConstants.CLAIM_ConsentProvidedText;
            }
            else if(modeCommunication == 'Email'){
                objConsentIns.LastEmailDate__c = system.now();
                objConsentIns.ConsentProvidedBy__c = RE_GlobalConstants.CLAIM_ConsentProvidedEmail;
            }
            else if(modeCommunication == 'Verbal')
            {
                objConsentIns.ConsentProvidedBy__c = RE_GlobalConstants.CLAIM_ConsentProvidedVerbal;
                objConsentIns.StartDate__c = system.today();
            }
            if(bIsAssister == true){
                objConsentIns.Assister__c = loggedInUserContactId;
                objConsentIns.ConsentLevel__c = sAssister;
                objConsentIns.Organization__c = loggedInUserAccountId;
            }
            else{
                objConsentIns.ConsentLevel__c = sOrganization;
                objConsentIns.Organization__c = loggedInUserAccountId;
            }
            RE_DataAccessChecker.insertObject(Consent__c.getSObjectType(), objConsentIns);
            
        }catch (Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl', 'insertConsent', e.getMessage(), true);
        }
        return fetchConsentRecord(objConsentIns.Id); 
    }
    
    /********************************************************************************************
* @author       Abhijeet Vaishnab
* @date         07/18/2019
* @methodname   fetchConsentRecord()
* @description  Method to Fetch Consent Record of a Client
* @return       Consent__c
**********************************************************************************************/    
    
    public static Consent__c fetchConsentRecord(String consentId){
        GeneralUtility.isAuthenticatedUser();
        Consent__c objConsent;
        List<Consent__c> consentList = new List<Consent__c>();
        if(consentId != null){
            Map<String, String> mapQueryParameters = new Map<String, String>();
            Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
            String sQuery;
            String sFieldsAPIName = RE_DataBaseQueryFields.sFieldsToQueryOnClientConsent;
            String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnExistingConsent;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.consentobjectName, sFieldsAPIName, mapQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapResponseData.get(true);
                    consentList = Database.query(sQuery);
                    if((!consentList.isEmpty())&& consentList.size()>0){
                        objConsent = consentList[0];
                    }
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','fetchConsentRecord','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            
            
            //List<Consent__c> consentList = [SELECT Id,Name,LastTextDate__c,LastEmailDate__c,Status__c,StartDate__c,EndDate__c,Assister__c,Organization__c,ConsentLevel__c,Client__c
            //                                FROM Consent__c WHERE Id =: consentId];
            
        }
        return objConsent;
    }
/********************************************************************************************
* @author       :Lagan Kankane
* @date         07/18/2019
* @methodname   updateConsentFromEmail(String consentId, Boolean accessgiven)
* @description  Method to update consent record from email.
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/ 
    
     @AuraEnabled
    public static RE_CreateLightningServerResponse updateConsentFromEmail(String consentId, Boolean accessgiven){
        GeneralUtility.isAuthenticatedUser();
        Consent__c objConsent;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        List<Consent__c> consentList = new List<Consent__c>();
        try{
            if(consentId != null){
                Map<String, String> mapQueryParameters = new Map<String, String>();
                Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
                String sQuery;
                String sFieldsAPIName = RE_DataBaseQueryFields.sFIeldsToQueryOnConsentHttpUpdate;
                String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnExistingConsent;
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
                mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.consentobjectName, sFieldsAPIName, mapQueryParameters);
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                switch on (switchCaseKey) {
                    when SWITCH_SUCCESS {
                        sQuery =  mapResponseData.get(true);
                        consentList = Database.query(sQuery);
                        if((!consentList.isEmpty())&& consentList.size()>0){
                            objConsent = consentList[0];
                            if(accessgiven){
                                objConsent.Status__c = RE_GlobalConstants.USER_STATUS_ACTIVE;
                                objConsent.StartDate__c = system.today();
                                objConsent.ConsentProvidedBy__c = RE_GlobalConstants.CLAIM_ConsentProvidedVerbal;
                                RE_DataAccessChecker.updateObject(Consent__c.getSObjectType(), objConsent);
                            }
                            
                            
                            bSuccess=true;
                            
                        }
                    }
                    when SWITCH_FAILURE {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','fetchConsentRecord','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                    }
                }
            }
        }
        
        catch(Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl', 'updateConsentFromEmail', e.getMessage(), true);
        }
        
        
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
 /********************************************************************************************
* @author       Prashant Singh
* @date         10/24/2019
* @methodname   updateConsentFromEmail(String consentId, Boolean accessgiven)
* @description  Method to update consent record from email.
* @return       RE_CreateLightningServerResponse
**********************************************************************************************/ 
    @AuraEnabled
    public static RE_CreateLightningServerResponse getConsents(){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        List<VerbalConsentSettings__mdt> lstRecords = new List<VerbalConsentSettings__mdt>();
        List<RE_RequestConsentModalCtrl.OptionsWrapper> wrapperlstRecords = new List<RE_RequestConsentModalCtrl.OptionsWrapper>();
        try{
            
            String currentlocale = UserInfo.getLocale();
            //Force Reviewer Changes- Payal Dubela - 08/28
            if(currentlocale!=null && RE_DataAccessChecker.isAllowedToAccess(VerbalConsentSettings__mdt.sObjectType)
                   && RE_DataAccessChecker.isSafeField('DeveloperName', 'VerbalConsentSettings__mdt')
                   && RE_DataAccessChecker.isSafeField('Id', 'VerbalConsentSettings__mdt')
                   && RE_DataAccessChecker.isSafeField('Label', 'VerbalConsentSettings__mdt')
                   && RE_DataAccessChecker.isSafeField('Label__c', 'VerbalConsentSettings__mdt')
                   && RE_DataAccessChecker.isSafeField('Language__c', 'VerbalConsentSettings__mdt')
                   && RE_DataAccessChecker.isSafeField('Value__c', 'VerbalConsentSettings__mdt')
                   && RE_DataAccessChecker.isSafeField('isAdditionalOption__c', 'VerbalConsentSettings__mdt')){
                       lstRecords=[SELECT DeveloperName,Id,Label,Label__c,Language__c,Value__c,isAdditionalOption__c FROM VerbalConsentSettings__mdt where Language__c!= null AND Language__c=:currentlocale order by Label asc];
            }    
            for(VerbalConsentSettings__mdt obj : lstRecords){
                RE_RequestConsentModalCtrl.OptionsWrapper objOption=new RE_RequestConsentModalCtrl.OptionsWrapper();
                objOption.label=obj.Label__c;
                objOption.value=obj.Value__c;
                objOption.isAdditionalOption=obj.isAdditionalOption__c;
                wrapperlstRecords.add(objOption);
            }
            mapResponse.put('records', wrapperlstRecords);
            bSuccess=true;
        }
        catch(Exception e) {errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl', 'getConsents', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /********************************************************************************************
    * @author       Prashant Singh
    * @date         29/08/2019
    * @methodname   getPickListValues()
    * @description  This methods is used to fetch the picklist values
    * @param        String objectName, String lstFields
    * @return       void 
    **********************************************************************************************/  
    @AuraEnabled  
    public static  RE_CreateLightningServerResponse getPickListValues(String objectName, String lstFields){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{}; 
           try { //SOQL injection made to the below line.
               Map<String, Map<String, String>> values = GeneralUtility.fetchFieldsPicklistValueAPIName(String.escapeSingleQuotes(objectName), String.escapeSingleQuotes(lstFields));
               bSuccess = true;
               mapResponse.put('picklistvalues', values);
          } catch(Exception e) {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','getPickListValues', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
   /********************************************************************************************
    * @author       Prashant Singh
    * @date         29/08/2019
    * @methodname   getContactDetails()
    * @description  This methods is used to fetch the picklist values
    * @param        String objectName, String lstFields
    * @return       void 
    **********************************************************************************************/   
    
    @AuraEnabled  
    public static  RE_CreateLightningServerResponse getContactDetails(String sContactId){
     GeneralUtility.isAuthenticatedUser();
     String conid=String.isNotBlank(sContactId)?String.escapeSingleQuotes(sContactId):'';
     Boolean bSuccess = false;
     Boolean bIsAssister=false;
     //Added By Kojashree -- SSP Merge Fixes
      String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
      Profile sProfile = GeneralUtility.getLoggedInUserProfile();
       /* if(sProfile.Name == RE_GlobalConstants.RE_ASSISTER_PROFILE){
            bIsAssister=true;
        }*/ // Updated By Kojashree -- SSP Merge
        if(selectedRole == RE_GlobalConstants.RE_ASSISTER_ROLE){
            bIsAssister=true;
        }
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Contact obj;
        RE_ContactWrapper objContactWrapper = new RE_ContactWrapper();
        try{
            //new addition
        String sFieldsApiNameForContact = RE_DataBaseQueryFields.sFieldsToQueryOnContactForWrapper;
        String sWhereClauseForContact = RE_DataBaseQueryFields.sWhereClauseOnContactForWrapper ;
        String sQuery;
        Map<String,String> mapQueryParameters = new Map<String,String>();
        
        String sOrderby = RE_DataBaseQueryFields.sOrderByForReferralTest;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForContact);
        mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        mapQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
                Map<Boolean,String> mapContact = RE_DataAccessChecker.getFieldsAccessibility('Contact',sFieldsApiNameForContact,mapQueryParameters);
        if(mapContact.get(true) != null){
            sQuery =  mapContact.get(true);
            
            obj = Database.query(sQuery);  
           
            if(obj.PreferredCommunicationMethod__c!=null && obj.PreferredCommunicationMethod__c!='')
                {
                    objContactWrapper.CommunicationPref=obj.PreferredCommunicationMethod__c;
                }
                if(obj.Phone!=null && obj.Phone!='')
                {
                    objContactWrapper.Phone=obj.Phone;
                }
                if(obj.Email!=null && obj.Email!='')
                {
                    objContactWrapper.Email=obj.Email;
                }
                if(obj.Name!=null && obj.Name!=''){
                    objContactWrapper.ClientName=obj.Name;
                }
                if(bIsAssister==true && GeneralUtility.getLoggedInUserContactName() != null && GeneralUtility.getLoggedInUserContactName() != ''){
                    objContactWrapper.LoggedInUserName= GeneralUtility.getLoggedInUserContactName();
                }else if(bIsAssister==false && GeneralUtility.getLoggedInUserAccount()!=null){
                    objContactWrapper.LoggedInUserName= GeneralUtility.getLoggedInUserAccount().Name;
                }
                objContactWrapper.bConsentToText = obj.ConsentToTexts__c;
                mapResponse.put('records', JSON.serialize(objContactWrapper));
                RE_CreateLightningServerResponse resp = RE_ClientDetailsCtrl.checkConsentWithStatus(conid,RE_GlobalConstants.CONSENT_STATUS_ACTIVE);
                mapResponse.put('hasActiveConsent', resp.objectData.get('hasActiveConsent') );
                bSuccess=  true;
        }else{
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_RequestConsentModalCtrl','execute','***FLS Violation***'+mapContact.get(false),true);
        }
                
                
                
            }   catch(Exception e) {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','getContactDetails', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    public class RE_ContactWrapper{
        @AuraEnabled
        public String sContactId{get;set;}
        @AuraEnabled
        public String Email{get;set;}
        @AuraEnabled
        public String Phone{get;set;}
        @AuraEnabled
        public String CommunicationPref{get;set;}
        @AuraEnabled
        public String LoggedInUserName{get;set;} //Anuj
        @AuraEnabled
        public String ClientName{get;set;}// Payal
        @AuraEnabled
        public Boolean bConsentToText {get;set;} //Kojashree
        
    }
    
    public class OptionsWrapper{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public Boolean isAdditionalOption {get; set;}
     }
    
/********************************************************************************************
    * @author       Lagan Kankane
    * @date         11/04/2019
    * @methodname   updateConsentOnVerbalRequest()
    * @description  This methods is used to update contact, consent(if not present then create), 
    *               and insert communicationlog__c record 
    * @param        String strConsentId, Boolean accessgiven,String contactId,String Email,
    *               String Phone,String PrefComm
    * @return       void 
    **********************************************************************************************/ 
     @AuraEnabled
    public static RE_CreateLightningServerResponse updateConsentOnVerbalRequest(String sConsentId,
                                                                                Boolean accessgiven,
                                                                                String strContactId,String strEmail,
                                                                                String strPhone,String strPrefComm,Boolean consentToText){
        GeneralUtility.isAuthenticatedUser();
        String strConsentId=String.isNotBlank(sConsentId)?String.escapeSingleQuotes(sConsentId):'';
        
        String contactId=String.isNotBlank(strContactId)?String.escapeSingleQuotes(strContactId):'';
        String Email=String.isNotBlank(strEmail)?String.escapeSingleQuotes(strEmail):'';
        String Phone=String.isNotBlank(strPhone)?String.escapeSingleQuotes(strPhone):'';
        String PrefComm=String.isNotBlank(strPrefComm)?String.escapeSingleQuotes(strPrefComm):'';
        Consent__c objConsent;
        Boolean bSuccess = false;
        Boolean bIsAssister = false;
        //RE Security Changes - Payal Dubela
        Account loggedInUserAccount=GeneralUtility.getLoggedInAccount();
        String loggedInUserContactId=GeneralUtility.getLoggedInUserContactId();
        String sOrganization=RE_GlobalConstants.ORGANIZATION;
        String sAssister=RE_GlobalConstants.ASSISTER;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        List<Consent__c> consentList = new List<Consent__c>();
        String consentId;
        if(!String.isEmpty(strConsentId)){
            consentId = String.escapeSingleQuotes(strConsentId);
        }
         
        try{
            // To query on if the user is assisster or not
            //RE Security Changes - Payal Dubela
            String sProfile = GeneralUtility.getLoggedInUserSelectedRole();
            if(sProfile!=null && sProfile.contains(RE_GlobalConstants.RE_ASSISTER_ROLE)){
                bIsAssister=true;
            }

            //assister query ends
            
            //to check if contact record exists, and to update it if if does
            //Force Reviewer Changes - Payal Dubela - 08/28 
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyconId = (contactId != null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyconId) {
             when SWITCH_SUCCESS {   
                List<Contact> contactList = new List<Contact>();
                Contact objContact;
                Map<String, String> mapQueryParametersContact = new Map<String, String>();
                Map<Boolean, String> mapResponseDataContact = new Map<Boolean, String>();
                String sQueryContact;
                String sFieldsAPINameContact = RE_DataBaseQueryFields.sFieldsToQueryOnContactForConsentClass;
                String sWhereClauseContact = RE_DataBaseQueryFields.sWhereClauseOnContactId;
                mapQueryParametersContact.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseContact);
                mapQueryParametersContact.put(RE_GlobalConstants.sLimitKey, '1');
                mapResponseDataContact = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strSobjectName, sFieldsAPINameContact, mapQueryParametersContact);
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyCon = (mapResponseDataContact.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                switch on (switchCaseKeyCon) {
                    when SWITCH_SUCCESS {
                        sQueryContact =  mapResponseDataContact.get(true);
                        contactList = Database.query(sQueryContact);
                        if((!contactList.isEmpty())&& contactList.size()>0){
                            objContact = contactList[0];
                           objContact.Email = Email;
                           objContact.Phone = Phone;
                           objContact.PreferredCommunicationMethod__c = PrefComm;
                           objContact.ConsentToTexts__c = consentToText == null ? false : consentToText; //Added by Kojashree

                           //update objContact;
                           //   RE_DataAccessChecker.updateObject(Contact.getSObjectType(), objContact);
                           RE_SharingByPassCtrl.updateSobject(Contact.getSObjectType(), objContact);
                            }
                            
                           }
                    
                    when SWITCH_FAILURE {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','updateConsentOnVerbalRequest','Some Fields doesn\'t have the required access :: '+mapResponseDataContact.get(false), true);
                    }
                }
            
            
            //
            
            //to check if consent record exists, and to update it if it does
            if(consentId != null && consentId != 'undefined'){
                Map<String, String> mapQueryParameters = new Map<String, String>();
                Map<Boolean, String> mapResponseDataConsent = new Map<Boolean, String>();
                String sQuery;
                String sFieldsAPIName = RE_DataBaseQueryFields.sWhereClauseOnConsentForConsentClass;
                String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnExistingConsent;
                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
                mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                mapResponseDataConsent = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.consentobjectName, sFieldsAPIName, mapQueryParameters);
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseDataConsent.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                switch on (switchCaseKey) {
                    when SWITCH_SUCCESS {
                        
                        sQuery =  mapResponseDataConsent.get(true);
                        consentList = Database.query(sQuery);
                        if((!consentList.isEmpty())&& consentList.size()>0){
                            objConsent = consentList[0];
                            if(accessgiven){
                                objConsent.Status__c = RE_GlobalConstants.USER_STATUS_ACTIVE;
                                objConsent.StartDate__c = system.today();
                                objConsent.ClientEmailProvided__c=Email;
                                objConsent.Client__c = contactId;
                                if(bIsAssister){
                                    objConsent.Assister__c = loggedInUserContactId;
                                    objConsent.Organization__c = loggedInUserAccount.Id;
                                    objConsent.ConsentLevel__c = RE_GlobalConstants.ASSISTER;
                                }
                                else{
                                    objConsent.ConsentLevel__c = RE_GlobalConstants.ORGANIZATION;
                                    objConsent.Organization__c = loggedInUserAccount.Id;
                                    
                                }
                                objConsent.ConsentProvidedBy__c = RE_GlobalConstants.CLAIM_ConsentProvidedVerbal;
                               objConsent.StartDate__c = system.today();
                               
                                RE_DataAccessChecker.updateObject(Consent__c.getSObjectType(), objConsent);
                            }
                            
                             }
                    }
                    when SWITCH_FAILURE {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','fetchConsentRecord','Some Fields doesn\'t have the required access :: '+mapResponseDataConsent.get(false), true);
                    }
                }
            }
            else{
                objConsent = insertConsent('Verbal',objContact,'Active',Email);
            }
            try{
                List<SurveyInvitation> lstSurveyInvites=RE_SharingByPassCtrl.fetchSurveyInvites(objConsent.Id);
                if(lstSurveyInvites!=null && lstSurveyInvites.size()>0){
                    for(SurveyInvitation s: lstSurveyInvites){
                        s.InviteExpiryDateTime=datetime.now();
                    }
                    RE_SharingByPassCtrl.updateSobjects(SurveyInvitation.getSObjectType(),lstSurveyInvites);
                }
            }
            catch(Exception e){
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','updateSurveyInvites','Error Occured:: '+ e.getMessage(), true);
            }
            
                //Logic to insert communicationlog__c record to send Email
               if ( EmailSetting__c.getInstance('Verbal Consent Mail').Is_on__c
                && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c) {
                    List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
                    CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
                    Database.SaveResult[] srCommunicationNubList;    
                    // Bug #350114: Starts added by Suresh                    
                    objCommunicationNub.EmailSubject__c = String.format(Label.RE_VerbalConsentSub, new List<String>{((bIsAssister==false) ? loggedInUserAccount.Name : GeneralUtility.getLoggedInUserContactName())});             
                    // Bug #350114: Ends added by Suresh 
                    String strEmailTemplateBody = String.format(Label.RE_VerbalConsentBody + Label.RE_VerbalConsentAdditionalBody, new List<String>{ objContact.FirstName,objContact.LastName,  ((bIsAssister==false) ? loggedInUserAccount.Name : GeneralUtility.getLoggedInUserContactName())});
                    strEmailTemplateBody+= Label.RE_doNotReplyMessage + ' ' + Label.RE_PIIMessage + '<br>'+Label.RE_SecurityMessage;
                    objCommunicationNub.TemplateBody__c= strEmailTemplateBody;
                    objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                    objCommunicationNub.ToEmail__c= Email; 
                      //Added By Kojashree
        			objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                    lstCommunicationNubInsert.add(objCommunicationNub);
                    RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeynubinsert = (lstCommunicationNubInsert!=null && lstCommunicationNubInsert.size() > 0) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                               
                    switch on (switchCaseKeynubinsert) {
                        when SWITCH_SUCCESS {                        
                            if(RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){   
                                RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                            }
                            else{
                                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_MyPlanCtrl.class.getName(), 'shareMyPlanDetails','No Access on CommunicationLog__c Object',true);
                            }
                        }
                    }
                } 
                //communication log record insertion end
                bSuccess=true;
            }
         }
        }
        
        catch(Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl', 'fetchConsentRecord', e.getMessage(), true);
        }
        
        
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }

 /********************************************************************************************
* @author       Kojashree Kakariya
* @date         09/01/2020
* @methodname   sendEmail()
* @description  Method to Send Consent Agreement email when consent is Active
* @return       
**********************************************************************************************/   
    // Release 1.1
    @InvocableMethod    
    public static void sendEmail(List<String> ConsentId){
        
        String sConsentId = ConsentId[0];
        
        List<Consent__c> lstConsentDetails = new List<Consent__c>();
        String sConsentQuery;
        String switchCaseKey;
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapConsentQueryParameters = new Map<String, String>();
        try{
             String sConsentFieldsApiName = RE_DataBaseQueryFields.sFieldsToQueryOnConsentObject;    
        String sFieldWhereCondition = RE_DataBaseQueryFields.sWhereClauseOnConsentObject;            
        mapConsentQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sFieldWhereCondition);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Consent__c', sConsentFieldsApiName, mapConsentQueryParameters);
        switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
        switch on (switchCaseKey) {
            when 'success' {
                sConsentQuery =  mapResponseData.get(true);
              //  lstConsentDetails = Database.query(sConsentQuery); 
               lstConsentDetails = RE_SharingByPassCtrl.fetchConsentRecord(sConsentQuery, sConsentId);
           
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl','sendEmail','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
       
       // Consent__c consentRec = [SELECT Id,Client__c,Client__r.FirstName,Client__r.LastName,ClientEmailProvided__c,Organization__c,Organization__r.Name,Assister__c FROM Consent__c WHERE Id=:sConsentId];
        Consent__c consentRec = new Consent__c();
        if(!lstConsentDetails.isEmpty()){
            consentRec = lstConsentDetails[0];
        }
        String OrganisationName = consentRec.Organization__r.Name;
        Boolean bIsAssister = false;
        String Email = consentRec.ClientEmailProvided__c;
        String conFirstName = consentRec.Client__r.FirstName;
        String conLastName = consentRec.Client__r.LastName;
        
       if ( (EmailSetting__c.getInstance('Consent Agreement Mail').Is_on__c  || EmailSetting__c.getInstance('Verbal Consent Mail').Is_on__c) && Email_Text_Communication_Settings__c.getInstance().Email_Communication__c) {
                List<CommunicationLog__c> lstCommunicationNubInsert = new List<CommunicationLog__c>();
                CommunicationLog__c objCommunicationNub = new CommunicationLog__c();
                Database.SaveResult[] srCommunicationNubList;    
                
                objCommunicationNub.EmailSubject__c = String.format(Label.RE_VerbalConsentSub, new List<String>{((bIsAssister==false) ? OrganisationName : GeneralUtility.getLoggedInUserContactName())});             
                
                String strEmailTemplateBody = String.format(Label.RE_VerbalConsentBody + Label.RE_VerbalConsentAdditionalBody, new List<String>{ conFirstName,conLastName,  ((bIsAssister==false) ? OrganisationName : GeneralUtility.getLoggedInUserContactName())});
                strEmailTemplateBody+= Label.RE_doNotReplyMessage + ' ' + Label.RE_PIIMessage + '<br>'+Label.RE_SecurityMessage;
                objCommunicationNub.TemplateBody__c= strEmailTemplateBody;
                objCommunicationNub.Status__c=RE_GlobalConstants.STATUS_INPROGRESS;
                objCommunicationNub.ToEmail__c= Email; 
                  //Added By Kojashree
        		objCommunicationNub.SourceSystem__c = RE_GlobalConstants.RE_SOURCESYSTEM;
                lstCommunicationNubInsert.add(objCommunicationNub);

                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeynubinsert = (lstCommunicationNubInsert!=null && lstCommunicationNubInsert.size() > 0) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                               
                switch on (switchCaseKeynubinsert) {
                    when SWITCH_SUCCESS {                        
                        if(RE_DataAccessChecker.isAllowedToCreate(CommunicationLog__c.getSObjectType())){   
                            RE_DataAccessChecker.insertObjects(CommunicationLog__c.getSObjectType(), lstCommunicationNubInsert, false);
                        }
                        else{
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_RequestConsentModalCtrl.class.getName(), 'updateConsent','No Access on CommunicationLog__c Object',true);
                        }
                    }
                }
       }
        //communication log record insertion end
       }catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl', 'sendEmail', e.getMessage(), true);
      }
    
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
            RE_ClientsHelper.DataTableWrapper clientData=(RE_ClientsHelper.DataTableWrapper)JSON.deserialize(IEESData,RE_ClientsHelper.DataTableWrapper.class);
            contactId=RE_CreateCitizenHelper.createContact(Integer.valueof(clientData.IEESId),clientData);
            RE_CreateLightningServerResponse response=fetchClientDetails(String.valueof(contactId));
            return response;
        }

    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchKogURL(){
         GeneralUtility.isAuthenticatedUser();
        RE_CreateLightningServerResponse objResponse;
        try{
            objResponse=RE_CartLoginModelCtrl.fetchKogURL();
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_RequestConsentModalCtrl', 'fetchKogURL', e.getMessage(), true);
        }
        return objResponse;
    }
}