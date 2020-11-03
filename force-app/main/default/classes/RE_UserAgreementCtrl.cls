/**
* Class Name    : RE_UserAgreementCtrl
* Owner         : CHFS
* Created Date  : 11/13/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer        Description                                                         
*  ----------  -----------      -------------------------------------------------------------------
*  11/13/2019  Siri Putta       Header login validations
*  08/19/2019  Venkat Korra     Changes related to RE Security Changes
**/
public with sharing class RE_UserAgreementCtrl {
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchLoginInUser(){
        
        String loggedInUser = GeneralUtility.getLoggedInUserSelectedRole();
        Boolean bGuestUser = UserInfo.getUserType() == RE_GlobalConstants.GUEST ? true : false;
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        
        Id loggedinUserId = UserInfo.getUserId();
        String sUserWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedUser;
        Map<String, String> mapUserQueryParameters = new Map<String, String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User','LastLoginDate,UserAgreementConsentDate__c,LanguageLocaleKey, profile.name', mapUserQueryParameters);           
        List<User> lstloggedInUser = RE_SharingByPassCtrl.getUserRecords(userQuery, loggedinUserId);
        //SIT Log message error fix - By Suresh
        String suserAgreementLanguage;
        String suserAgreementProfileName;
        if(!lstloggedInUser.isEmpty()){
             suserAgreementLanguage = lstloggedInUser[0].LanguageLocaleKey;
        }
        //SIT Log message error fix - By Suresh

        try{
            if(loggedInUser == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || loggedInUser == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF){
                mapResponse.put('isCpUser', true);
                suserAgreementProfileName = RE_GlobalConstants.strCommunityProfileName;
            }
            if(loggedInUser == RE_GlobalConstants.CITIZEN_INDIVIDUAL)
            {
                mapResponse.put('isResidentUser', true);
                suserAgreementProfileName = RE_GlobalConstants.strCitizenProfileName;
            }
            if(loggedInUser == RE_GlobalConstants.RE_ASSISTER_ROLE)
            {
                mapResponse.put('isAssisterUser', true);
                suserAgreementProfileName = RE_GlobalConstants.RE_ASSISTER_PROFILE;
            }
            mapResponse.put('isGuestUser', bGuestUser);
            //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
            RE_User_Agreement__mdt[] activeUserAgreement;
            if(Schema.sObjectType.RE_User_Agreement__mdt.fields.MasterLabel.isAccessible() && Schema.sObjectType.RE_User_Agreement__mdt.fields.DeveloperName.isAccessible() &&
              Schema.sObjectType.RE_User_Agreement__mdt.fields.Header__c.isAccessible() && Schema.sObjectType.RE_User_Agreement__mdt.fields.Status__c.isAccessible() && 
              Schema.sObjectType.RE_User_Agreement__mdt.fields.Text__c.isAccessible() && Schema.sObjectType.RE_User_Agreement__mdt.fields.userType__c.isAccessible() &&
              Schema.sObjectType.RE_User_Agreement__mdt.fields.Version__c.isAccessible() && Schema.sObjectType.RE_User_Agreement__mdt.fields.Language__c.isAccessible()
              && Schema.sObjectType.RE_User_Agreement__mdt.fields.status__c.isAccessible() && suserAgreementLanguage!=null && suserAgreementProfileName!=null){
                activeUserAgreement = [SELECT MasterLabel ,DeveloperName, Community_Name__c, Header__c, Status__c, Text__c,userType__c, Version__c,Language__c FROM RE_User_Agreement__mdt WHERE Community_Name__c = 'RE' AND Language__c=:suserAgreementLanguage AND userType__c=:suserAgreementProfileName AND status__c='Active' AND Language__c != null LIMIT 1];
            }
            
            if(!activeUserAgreement.isEmpty()){ //SIT Log message error fix - By Suresh
                mapResponse.put('activeUserAgreementVersion',activeUserAgreement[0].Version__c);
                mapResponse.put('activeUserAgreementText',activeUserAgreement[0].Text__c);
                mapResponse.put('activeUserAgreementHeader',activeUserAgreement[0].Header__c);
                mapResponse.put('activeUserAgreementLanguage',activeUserAgreement[0].Language__c);
            }
            bSuccess = true;
        }catch(exception ex){
            errorMap.put('error',ex.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserAgreementCtrl','fetchLoginInUser','Error Occured:: '+ ex.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
}