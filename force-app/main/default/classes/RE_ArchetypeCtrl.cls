/**
* Class Name    : RE_ArchetypeCtrl
* Owner         : DELOITTE
* Created Date  : 07/04/2019
* Description   : Controller class for RE_Archetype Aura Component
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/04/2019  Deeksha      Initial Version
**/
public with sharing class RE_ArchetypeCtrl {       
    /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/04/2019
    * @methodname   processUserInfo()
    * @description  This methods is used to process the user information
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse processUserInfo(String strarchId){
        
        String archId = String.escapeSingleQuotes(strarchId);
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        String sUserQuery;
        User objLoggedInUser = new user();
        try{
            Id loggedinUserId = UserInfo.getUserId();
            String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUser;//'Id,ContactId,Contact.MailingPostalCode,Profile.Name';
            String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseGetLoggedUser;
            Map<String,String> mapQueryParameters = new Map<String,String>();
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
            if(UserInfo.getUserType() == RE_GlobalConstants.GUEST_USERTYPE){
                mapResponse.put('isGuestUser',true);
            }
            else{
                mapResponse.put('isGuestUser',false);
                sUserQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.userobjectName, sFieldsToQueryOnUser, mapQueryParameters);
                objLoggedInUser = Database.query(sUserQuery);
                if(objLoggedInUser.ContactId!=null && !String.isBlank(objLoggedInUser.Contact.MailingPostalCode)){
                    String loggedInUserAddress='';
                    if(objLoggedInUser.Contact.MailingStreet!=null && String.isNotBlank(objLoggedInUser.Contact.MailingStreet)){
                        loggedInUserAddress+=objLoggedInUser.Contact.MailingStreet+',';
                    }
                    if(objLoggedInUser.Contact.MailingCity!=null && String.isNotBlank(objLoggedInUser.Contact.MailingCity)){
                        loggedInUserAddress+=objLoggedInUser.Contact.MailingCity+',';
                    }
                    if(objLoggedInUser.Contact.MailingState!=null && String.isNotBlank(objLoggedInUser.Contact.MailingState)){
                        loggedInUserAddress+=objLoggedInUser.Contact.MailingState+',';
                    }
                    if(objLoggedInUser.Contact.MailingCountry!=null && String.isNotBlank(objLoggedInUser.Contact.MailingCountry)){
                        loggedInUserAddress+=objLoggedInUser.Contact.MailingCountry+',';
                    }
                    if(objLoggedInUser.Contact.MailingPostalCode!=null && String.isNotBlank(objLoggedInUser.Contact.MailingPostalCode)){
                        loggedInUserAddress+=objLoggedInUser.Contact.MailingPostalCode;
                    }
                    //
                    mapResponse.put('zipCodeProfile',loggedInUserAddress); 
                    mapResponse.put('mylocationdata',jSON.serialize(objLoggedInUser));
                }else{
                    mapResponse.put('zipCodeProfile','');                    
                }
            }
            if(String.isNotBlank(archId)){
                List<RE_Archetype__c> archTypeRecords = RE_ArchetypeCtrl.getRelatedArcheTypes(archId);
                if(archTypeRecords!=NULL && archTypeRecords.Size()>0){
                    mapResponse.put('archTypeRecords',archTypeRecords);
                }
            }
            
            Map<String,String> mapAvailableDomains = RE_ArchetypeCtrl.getRelatedDomains();
            if(mapAvailableDomains!=null){
                mapResponse.put('mapAvailableDomains',mapAvailableDomains); 
            }            
            
            bSuccess = true;
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeCtrl.class.getName(), 'processUserInfo', e.getMessage()+' '+e.getStackTraceString(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Akash Sharma
    * @date         07/05/2019
    * @methodname   getRelatedArcheTypes()
    * @description  This methods is used to get related Archetypes
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static List<RE_Archetype__c> getRelatedArcheTypes(String archId){
        Boolean bSuccess = false;
        Map<String, Object> errorMap    = new Map<String, Object>();
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        String sUserQuery;
        List<RE_Archetype__c> relatedArcheTypeRec = new List<RE_Archetype__c>();
        String archTypeId = String.escapeSingleQuotes(archId);
        try{
            Map<String,String> mapQueryParameters = new Map<String,String>();
            String sFieldsToQueryOnArcheType = RE_DataBaseQueryFields.sFieldsToQueryOnArcheType;
            String sWhereClauseForArcheType = RE_DataBaseQueryFields.sWhereClauseGetRelatedArcheType;
            String sQuery;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseForArcheType);
            Map<Boolean,String> mapResponseReferral = RE_DataAccessChecker.getFieldsAccessibility('RE_Archetype__c',sFieldsToQueryOnArcheType,mapQueryParameters);
            if(mapResponseReferral.get(true) != null){
                sQuery =  mapResponseReferral.get(true);
                relatedArcheTypeRec = Database.query(sQuery); 
                
            }else{
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ArchetypeCtrl','getRelatedArcheTypes','***FLS Violation***'+mapResponseReferral.get(false),true);
            } 
        }catch(Exception e){
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeCtrl.class.getName(), 'getRelatedArcheTypes', e.getMessage()+' '+e.getStackTraceString(), true);
        }
        return relatedArcheTypeRec;
    }
    // added by Pankaj 
    @AuraEnabled(cacheable=true)
    public static RE_CreateLightningServerResponse getArchetypeResources(String strZipCodeParam, String strArchetypeIdParam, String strSubArchetypeIdParam, String strDomainParam, String strGoalParam, String strSeeAllLess,List<String> selectedHours){
        return RE_ArchetypeDetailCtrl.getArchetypeResources(String.escapeSingleQuotes(strZipCodeParam), String.escapeSingleQuotes(strArchetypeIdParam), String.escapeSingleQuotes(strSubArchetypeIdParam), String.escapeSingleQuotes(strDomainParam), String.escapeSingleQuotes(strGoalParam), String.escapeSingleQuotes(strSeeAllLess),selectedHours);
    }
    
    /********************************************************************************************
    * @author       Nupoor Nimbalkar
    * @date         07/10/2019
    * @methodname   getRelatedDomains()
    * @description  This methods is used to get related Domains of Archetype
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static Map<String,String> getRelatedDomains(){        
        Map<String,String> mapAvailableDomains = new Map<String,String>();
        String sFieldsOnDomain = RE_DataBaseQueryFields.sFieldsOnDomain;
        Map<Boolean,String> mapResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strConfigObjectName,sFieldsOnDomain,null);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                Schema.DescribeFieldResult fieldResult = RE_Config__c.Domain__c.getDescribe();
                Schema.sObjectField field = fieldResult.getSObjectField();
                List<PicklistEntry> entries = field.getDescribe().getPicklistValues();
                
                for(PicklistEntry key : entries){
                    mapAvailableDomains.put(key.getLabel(), key.getValue());
                }
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_ArchetypeCtrl.class.getName(), 'getRelatedDomains', RE_GlobalConstants.FLS_ERROR + '' + mapResponse.get(false), true);
            }
        }        
        
        return mapAvailableDomains;
    }
    
    /********************************************************************************************
	* @author       Ashwin Kasture
	* @date         15/07/2019
	* @methodname   insertReferralForResident()
	* @description  This methods is used to insert the referral
	* @param        String objResource
	* @return       RE_CreateLightningServerResponse  
	**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReferralForResident(String strobjResource, String locationID, Boolean bConsentAgreed){
        String objResource = strobjResource;
        //RE_Release 1.4 – Iron Dome Changes(07/14) - Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> mapRespone = (Map<String, Object>)JSON.deserializeUntyped(objResource);
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapLighnResponse = new Map<String, Object>();
        List<Referral__c> referrallst = new List<Referral__c>();
        Boolean accountIsClaimed = false;
        String accountStatus = '';
        
        if(mapRespone.get('accountIsClaimed') != null){
            accountIsClaimed = Boolean.valueOf(mapRespone.get('accountIsClaimed'));
        }
        if(mapRespone.get('accountStatus') != null){
            accountStatus = String.valueOf(mapRespone.get('accountStatus'));
        }
             
        try{
            Referral__c objReferral= new Referral__c();
            if(accountIsClaimed && accountStatus == RE_GlobalConstants.sAccountStatus){
                objReferral.Status__c= RE_GlobalConstants.STATUS_NEW;
            }else if(!accountIsClaimed){
                objReferral.Status__c= RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
            } 
            Id contactId = GeneralUtility.getLoggedInUserContactId();
            objReferral.Contacts__c = contactId;
            objReferral.Location__c = locationID;
            objReferral.Resource__c = (Id)mapRespone.get('resourceId');
            objReferral.ReferredAccountID__c = (Id)mapRespone.get('accountId');
            objReferral.OwnerId = UserInfo.getUserId();
            objReferral.DateOfReferral__c = Date.today();
            objReferral.Source__c= RE_GlobalConstants.ADDED_BY_RESIDENT;
           
            //added for archetype id
            objReferral.Archetype__c=(Id)mapRespone.get('sArchetypeid');
            
            RE_SharingByPassCtrl.insertReferral(objReferral);   
            bSuccess = true;  
            if(bConsentAgreed){
                Account objAccount = new Account();
                objAccount.Id = GeneralUtility.getLoggedInUserAccountId();
                objAccount.HasOptedOutOfAccount__c = false;
                RE_SharingByPassCtrl.updateSobject(Account.getSObjectType(), objAccount);
            }
            mapLighnResponse.put('referals',objReferral);
        }catch(Exception e){
            errorMap.put('error',e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ArchetypeCtrl', 'insertReferralForResident', e.getMessage()+' '+e.getStackTraceString(), true);}
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapLighnResponse);        
    }

    /********************************************************************************************
    * @author       Sai Kiran
    * @date         08/19/2019
    * @methodname   getOptOutInfoSharingDetails()
    * @description  This methods is used to get OptOutInfoSharing Information from Account
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getOptOutInfoSharingDetails(){
        return RE_MyPlanCtrl.getOptOutInfoSharingDetails();
    }
    
    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         08/19/2019
    * @methodname   connectDraftReferralsFromArcheTypeResults()
    * @description  This methods is used to connect Draft Referrals
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse connectDraftReferralsFromArcheTypeResults(String sAchReferralId, Boolean bAchConsentAgreed){
        //RE_Release 1.4 – Iron Dome Changes(07/14) - Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        return RE_MyPlanCtrl.connectDraftReferrals(String.escapeSingleQuotes(sAchReferralId), bAchConsentAgreed);
    }
    
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/07/2019
    * @methodname   createFavorite()
    * @description  This methods is used to create favorite object
    * @param        (String sLocationResId)
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse createFavorite(String strLocationResId){
        return RE_SharingByPassCtrl.createFavorite(String.escapeSingleQuotes(strLocationResId));
    }
    
}