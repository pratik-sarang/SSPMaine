/**
* Class Name    : RE_GlobalThemeCtrl
* Owner         : DELOITTE
* Created Date  : 06/25/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/20/2019  SRIKANTH       Header login validations
*  07/28/2020  SIRI           New RE Security Changes
**/
public with sharing class RE_GlobalThemeCtrl {
	@AuraEnabled
    public static RE_CreateLightningServerResponse fetchLoginInUser(){
        
        string loggedInUser = GeneralUtility.getLoggedInUserSelectedRole();
        Boolean bGuestUser = UserInfo.getUserType() == RE_GlobalConstants.GUEST ? true : false;
        
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        
        
        
        Id loggedinUserId = UserInfo.getUserId();
        String sUserWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedUser;
        Map<String, String> mapUserQueryParameters = new Map<String, String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        // String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User','LastLoginDate,ContactId', mapUserQueryParameters); 
        String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User','LastLoginDate,ContactId,IsOnboardTrainingDone__c', mapUserQueryParameters);//added by Ram          
        List<User> lstloggedInUser = Database.query(userQuery);
        Id userContactId = lstloggedInUser[0].ContactId;
        
        String sContactWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedContact;
        String sContactSafeQuery;
        Map<String, String> mapContactQueryParameters = new Map<String, String>();            
        mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sContactWhereClause);
        mapContactQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        Boolean bisUserFirstLogin; 
        Boolean bisOnboardTrainingDone = lstloggedInUser[0].IsOnboardTrainingDone__c;
        if(UserInfo.getUserType() != RE_GlobalConstants.GUEST){
            Map<Boolean, String> mapResponseContact = RE_DataAccessChecker.getFieldsAccessibility('Contact', 'CompletedFirstTime__c', mapContactQueryParameters);
           
            
            if (mapResponseContact.get(true) != null) {
                sContactSafeQuery = mapResponseContact.get(true);
                
            } else {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ThemeCtrl','fetchLoginInUser','Some Fields do not have the required access on contact object ' + mapResponseContact.get(false),true);
            }
            Contact con = new Contact();
            if (sContactSafeQuery != null && bGuestUser == false) {
                con = Database.query(sContactSafeQuery);
                bisUserFirstLogin = con.CompletedFirstTime__c;
            } 
        }
        try{
            if(loggedInUser == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || loggedInUser == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF){
                mapResponse.put('isCpUser', true);
            }
            if(loggedInUser == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || loggedInUser == RE_GlobalConstants.CASE_WORKER){
                mapResponse.put('isAgencyUser', true);
            }
            if(loggedInUser == RE_GlobalConstants.ASSISTER){
                mapResponse.put('isAssisterUser', true);
            }
            mapResponse.put('isGuestUser', bGuestUser);
            
            if(loggedInUser == RE_GlobalConstants.strCitizenAppRole){
               mapResponse.put('isResidentUser', true);
               mapResponse.put('isUserFirstLogin', bisUserFirstLogin);
            }
            mapResponse.put('isCPOnboardingTrainingDone', bisOnboardTrainingDone);
            // Venkat: 1/27/2020: Added to show cart count on Help Pages
            // RE_Release 1.1 � Perf - Prashant � Moved in the condition below for perf after CHFS confirmation
            if(loggedInUser == RE_GlobalConstants.strCitizenAppRole){
            mapResponse.put('draftReferralCount', RE_MyPlanCtrl.getDraftReferralCount());
            }
            //start LMS change  
            //RE_Release 1.1 � Perf - Prashant � Moved in the condition below for perf after CHFS confirmation
            //Id planId = RE_LMSUtility.getPlanId(RE_GlobalConstants.LearningPlanName);
            //mapResponse.put('planId', planID);
            List<Id> userIds = new  List<Id>();
            userIds.add(loggedinUserId);
            if(mapResponse.get('isCpUser') == true && !bisOnboardTrainingDone){
                RE_LMSUtility.assignCPUserOnboardingTraining(userIds);   
                
            Id planId = RE_LMSUtility.getPlanId(RE_GlobalConstants.LearningPlanName);
            mapResponse.put('planId', planID);
            }
            List<String> availableRoles=GeneralUtility.getUserRolesforHeaderCmp();
            mapResponse.put('availableRoles', availableRoles);
             boolean isAvailableRoleSizeOne = availableRoles.size()==1? false: true;//[Suresh]
            mapResponse.put('isAvailableRoleSizeOne', isAvailableRoleSizeOne);
            GeneralUtility.SelectedRole=GeneralUtility.getLoggedInUserSelectedRole();
            mapResponse.put('SelectedRole', new List<String>{GeneralUtility.SelectedRole});
            //GeneralUtility.assignPS(new List<String>{GeneralUtility.SelectedRole});
            GeneralUtility.assignPS(availableRoles);
            bSuccess = true;
        }catch(exception ex){
            errorMap.put('error',ex.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_GlobalThemeCtrl','fetchLoginInUser','Error Occured:: '+ ex.getMessage(), true);
            //Shikha: added log message utility in catch blocks to incorporate code review comments
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
            
    @AuraEnabled
    public static RE_CreateLightningServerResponse kogLogout(){
        //GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        try{
            KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG CP Admin');
            String kogLogoutURL = objKog.KogLogoutURL__c;
            mapResponse.put('koglogout', kogLogoutURL);
        }catch(exception ex){
            errorMap.put('error',ex.getMessage());
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchCPUserTrainingStatus(){
        // RE Security Changes - Guest User Security- Payal Dubela
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        Id loggedInUserId = UserInfo.getUserId();
        if(loggedInUserId != null){
        try{
                User usr = new User();
                if(Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.IsOnboardTrainingDone__c.isAccessible()){
                    usr =  [SELECT Id, IsOnboardTrainingDone__c FROM User WHERE Id = :loggedInUserId AND Id != null];
                }
            mapResponse.put('isCPOnboardingTrainingDone', usr.IsOnboardTrainingDone__c);
            bSuccess = true;
        }catch(exception ex){
            errorMap.put('error',ex.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_GlobalThemeCtrl','fetchCPUserTrainingStatus','Error Occured:: '+ ex.getMessage(), true);
        }
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    @AuraEnabled
     public static void roleChange(String newRole){
         // RE Security Changes - Guest User Security- Payal Dubela
        GeneralUtility.isAuthenticatedUser();
         Map<String, Object> errorMap = new Map<String, Object>();
         List<String> roles=new List<String>();
         string loggedInUserSelectedRole = GeneralUtility.getLoggedInUserSelectedRole();
         try{
             if(loggedInUserSelectedRole !=newRole){
             String uId=UserInfo.getUserId();
             User u=[Select id,RE_Selected_Role__c from User where id=:uId];
             if(newRole.equalsIgnoreCase('Citizen')){//[Suresh] handle Citizen api 
                 u.RE_Selected_Role__c='Citizen_Individual';
             }
            else if(newRole.equalsIgnoreCase('kynector')){
                  u.RE_Selected_Role__c='Assister';
             }
             else{
                 u.RE_Selected_Role__c=newRole;
             }
             update u;
             roles.add(newRole);
             roles.add(loggedInUserSelectedRole);
             GeneralUtility.SelectedRole=newRole;
             //GeneralUtility.assignPS(roles);
            }
         }
         catch(exception ex){
            errorMap.put('error',ex.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_GlobalThemeCtrl','roleChange','Error Occured:: '+ ex.getMessage(), true);
        }
     }
}