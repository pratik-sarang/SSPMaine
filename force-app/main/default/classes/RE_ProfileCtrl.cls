/**
* Class Name    : RE_ProfileCtrl
* Owner         : DELOITTE
* Created Date  : 07/08/2019
* Description   : Controller class for Resident Registration 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/08/2019  Payal           Initial Version
**/
public with sharing class RE_ProfileCtrl {
    
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         07/08/2019
    * @methodname   getPicklistValues()
    * @description  This methods is used to get picklistValues 
    ******************************************************************************************/
    @AuraEnabled
    public static  RE_CreateLightningServerResponse getPickListValues(String strObjectName, String strLstFields){
        
        String objectName = String.escapeSingleQuotes(strObjectName);
        String lstFields = String.escapeSingleQuotes(strLstFields);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try {
                    Map<String, Map<String, String>> values = GeneralUtility.fetchFieldsPicklistValueAPIName(objectName, lstFields);
                    bSuccess = true;
                    mapResponse.put('picklistvalues', values);
                } catch(Exception e) {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDetailsCtrl','getPickListValues', e.getMessage(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }

    /**************************************************************************************
    * @author       Payal Dubela
    * @date         07/09/2019
    * @methodname   getArchetypes()
    * @description  This methods is used to get all the archetypes
    ******************************************************************************************/
    @AuraEnabled
    public static  RE_CreateLightningServerResponse getArchetypes(){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, String> mapQueryParameters = new Map<String, String>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        List<RE_Archetype__c> listArchetype= new List<RE_Archetype__c>();
        List<Contact> conList=new List<Contact>();
        Boolean bIsCPUserProfile = false;
        Boolean bIsAgencyUserProfile = false;//RE_Release 1.1 - Agency User Capture- Mohan
        Boolean bIsAssister = false;
        Id archetypeRecordtypeId=GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sArchetypeObjName,RE_GlobalConstants.strArchetypeRecordtypeName);
        String sQuery;
        String sFieldsApiName;
        List<Location__c> lstLocation = new List<Location__c>();

        try {
        //Getting Contact Details
        String contactId=GeneralUtility.getLoggedInUserContactId();
        Profile sProfile = GeneralUtility.getLoggedInUserProfile();
         //Added By Kojashree -- SSP Merge
        String sRole = GeneralUtility.getLoggedInUserSelectedRole();
            // added by Pankaj as part of ONEVIEW-1531
      /*  if(sProfile.Name == RE_GlobalConstants.strCommunityProfileName || sProfile.Name == RE_GlobalConstants.RE_ASSISTER_PROFILE){
          bIsCPUserProfile = true;
        }
        if(sProfile.Name == RE_GlobalConstants.strAgencyProfileName){
            bIsAgencyUserProfile=true;
         }
        if(sProfile.Name == RE_GlobalConstants.RE_ASSISTER_PROFILE){
           bIsAssister=true;
        }*/
        // Added By Kojashree -- SSP Merge 
        if(sRole == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN ||sRole == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF || sRole == RE_GlobalConstants.ASSISTER){
                bIsCPUserProfile = true;           
        }
            
        if(sRole == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || sRole == RE_GlobalConstants.CASE_WORKER){
                bIsAgencyUserProfile = true;       
         }
        if(sRole == RE_GlobalConstants.ASSISTER){
                bIsAssister=true;        
        }
            
        //Force Reviewer - Payal Dubela - 27/08
        sFieldsApiName=(bIsCPUserProfile || bIsAgencyUserProfile)?(bIsAssister?RE_DataBaseQueryFields.sFieldsToQueryOnMyAccountAssister:GeneralUtility.getFieldsFromFieldSet(RE_GlobalConstants.strSobjectName,RE_GlobalConstants.strContactFieldSetForMyAccount)):GeneralUtility.getFieldsFromFieldSet(RE_GlobalConstants.strSobjectName,RE_GlobalConstants.strContactFieldSetForRegistration);
        
        String sWhereClause=RE_DataBaseQueryFields.sWhereClauseOnContactForRegistration;
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strSobjectName, sFieldsApiName, mapQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sQuery =  mapResponseData.get(true);
                conList = Database.query(sQuery); 
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl','getArchtype','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        mapResponse.put('bIsCPUserProfile',bIsCPUserProfile);
        mapResponse.put('bIsAgencyUserProfile',bIsAgencyUserProfile);//RE_Release 1.1 - Agency User Capture- Mohan
        mapResponse.put('bIsAssister',bIsAssister);
        mapResponse.put('contactdetails',conList);

         //Getting Archtypes
        sFieldsApiName = GeneralUtility.getFieldsFromFieldSet(RE_GlobalConstants.sArchetypeObjName,RE_GlobalConstants.sArchetypeFieldSetName);
        sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnArchetype;
            
        mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
        mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sArchetypeObjName, sFieldsApiName, mapQueryParameters);
        switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sQuery =  mapResponseData.get(true);
                listArchetype = Database.query(sQuery); 
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl','getArchtype','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
            }
        }
        mapResponse.put('archetypes',listArchetype);
        //Getting User details
         String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnClientUser;
         String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnCitizenUser;
         User objUserdata = new User();
         mapQueryParameters = new Map<String,String>();
         mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
         mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
         String sUserQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.userobjectName, sFieldsToQueryOnUser, mapQueryParameters);
         List<User> userList=new List<User>();
         userList=Database.query(sUserQuery);
         mapResponse.put('userdetails',userList.isEmpty()?null:userList[0]);
        if(bIsCPUserProfile || bIsAgencyUserProfile){
            Id locationRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.strLocationObjectName, RE_GlobalConstants.LOCATION);
            String sFieldsToQueryOnLocation = RE_DataBaseQueryFields.sFieldsToQueryOnLocation;
            String sWhereClauseOnLocation = RE_DataBaseQueryFields.sWhereClauseOnLocation;
            Map<String,String> mapLocationQueryParameters = new Map<String,String>();
            mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocation);
            mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
            Map<Boolean,String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocationObjectName, sFieldsToQueryOnLocation, mapLocationQueryParameters);
            switchCaseKey = (mapLocationQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchCaseKey) {
                when SWITCH_SUCCESS {
                    sQuery =  mapLocationQueryResponse.get(true);
                    lstLocation = Database.query(sQuery); 
                }
                when SWITCH_FAILURE {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCtrl.class.getName(), 'getWrapper', RE_GlobalConstants.FLS_ERROR + '' + mapLocationQueryResponse.get(false), true);
                }
            }
          mapResponse.put('lstLocations',lstLocation);
        }
        
         bSuccess = true;
        }catch(Exception e) {
             errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl','getArchetypes', e.getMessage(), true);
        } 
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);


    }
     /**************************************************************************************
    * @author       Payal Dubela
    * @date         07/08/2019
    * @methodname   getPicklistValues()
    * @description  This methods is used to get picklistValues 
    ******************************************************************************************/
    @AuraEnabled
    //Updated by Kojashree Release 1.1 Defect : 357704 
    public static  RE_CreateLightningServerResponse submitResidentInfo(Contact contantInfo, Boolean optOutFlag,Boolean hasConsentToText){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Database.SaveResult[] contactList;
        Database.SaveResult[] accList;
        try {
           Contact contactRecord= new Contact();
           contactRecord=contantInfo;
           contactRecord.CompletedFirstTime__c=true;
           contactRecord.ConsentToTexts__c = hasConsentToText == null ? false : hasConsentToText; //Added by Srikanth for ErrorLogs
           //contactRecord.ConsentToTexts__c = hasConsentToText;// Release 1.1 Added by Kojashree
            String contactRecordId = contactRecord.Id;
            if(RE_DataAccessChecker.isAllowedToUpdate(Contact.getSObjectType())){ 
                contactList = RE_DataAccessChecker.updateObject(Contact.getSObjectType(),contactRecord);
                bSuccess=true;
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl', 'submitResidentInfo','Missing Create permission', true);
            } 
            //START
            List<String> lstConsentLevel = new List<String>{RE_GlobalConstants.ORGANIZATION,RE_GlobalConstants.ASSISTER};
            List<String> lstConsentStatus = new List<String>{RE_GlobalConstants.ACTIVE,RE_GlobalConstants.PENDING};
            List<Consent__c> lstConsentData = new List<Consent__c>();
            List<Consent__c> lstConsent = new List<Consent__c>();
            
            String sConsentSafeQuery;
            String switchCaseKeyConsent;
            Map<Boolean, String> mapResponseDataConsent = new Map<Boolean, String>();
            Map<String, String> mapConsentParameters = new Map<String, String>();
            String sConsentFieldsApiName = RE_DataBaseQueryFields.sFieldConsentFieldsStatus;    
            String sFieldConsentWhereCondition = RE_DataBaseQueryFields.sFieldConsentWhereConditionStatus1;            
            mapConsentParameters.put(RE_GlobalConstants.sWhereClauseKey, sFieldConsentWhereCondition);
            mapResponseDataConsent = RE_DataAccessChecker.getFieldsAccessibility('Consent__c', sConsentFieldsApiName, mapConsentParameters);
            switchCaseKeyConsent = (mapResponseDataConsent.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (switchCaseKeyConsent) {
                when 'success' {
                    sConsentSafeQuery =  mapResponseDataConsent.get(true);
                    lstConsentData = Database.query(sConsentSafeQuery); 
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl','submitResidentInfo','Some Fields doesn\'t have the required access :: '+mapResponseDataConsent.get(false), true);
                }
            }
            
            for(Consent__c consent : lstConsentData ){
                if(consent.Status__c == RE_GlobalConstants.ACTIVE ){
                    consent.Status__c = RE_GlobalConstants.INACTIVE;
                    consent.EndDate__c = System.today()-1;
                    lstConsent.add(consent);
                }
                if(consent.Status__c == RE_GlobalConstants.PENDING){
                    consent.Status__c = RE_GlobalConstants.INACTIVE;
                    lstConsent.add(consent);
                }
            }
            
            
         
            //END 
           Account accountRecord=new Account();
           accountRecord.Id=contactRecord.AccountId;
           accountRecord.HasOptedOutOfAccount__c=optOutFlag;
           if(RE_DataAccessChecker.isAllowedToUpdate(Account.getSObjectType())){ 
                   accList = RE_DataAccessChecker.updateObject(Account.getSObjectType(),accountRecord);
                //START
                if(accountRecord.HasOptedOutOfAccount__c == true && !lstConsent.isEmpty() ){
                    Database.SaveResult[] sr = RE_DataAccessChecker.updateObjects(Consent__c.sObjectType, lstConsent);
                }
                //END
               bSuccess=true;
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl', 'submitResidentInfo','Missing Create permission', true);
            } 
           
        }catch (Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl', 'submitResidentInfo', e.getMessage(), true);
        }
       return new RE_CreateLightningServerResponse(bSuccess, errorMap, null);

    }
    /**************************************************************************************
    * @author       Payal Dubela
    * @date         07/18/2019
    * @methodname   updateCPUserInfo()
    * @description  This methods is used to get update Information for CP Users 
    ******************************************************************************************/
    @AuraEnabled
    public static  RE_CreateLightningServerResponse updateCPUserInfo(Contact contantInfo){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Database.SaveResult[] contactList;
        try {
           Contact contactRecord= new Contact();
           contactRecord=contantInfo;
           contactRecord.CompletedFirstTime__c=true;
           
            if(RE_DataAccessChecker.isAllowedToUpdate(Contact.getSObjectType())){ 
                contactList = RE_DataAccessChecker.updateObject(Contact.getSObjectType(),contactRecord);
                bSuccess=true;
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl', 'updateCPUserInfo','Missing Create permission', true);
            } 
           
        }catch (Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ProfileCtrl', 'updateCPUserInfo', e.getMessage(), true);
        }
       return new RE_CreateLightningServerResponse(bSuccess, errorMap, null);

    }
    

}