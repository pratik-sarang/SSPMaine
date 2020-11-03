/**
* Class Name    : RE_ThemeCtrl
* Owner         : DELOITTE
* Created Date  : 06/25/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  07/20/2019  SRIKANTH       Header login validations
*  
**/
public with sharing class RE_ThemeCtrl {
	   
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchLoginInUser(){
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        try{
        String loggedInUser = GeneralUtility.getLoggedInUserSelectedRole();
        Boolean bGuestUser = UserInfo.getUserType() == RE_GlobalConstants.GUEST ? true : false;
        Id loggedinUserId = UserInfo.getUserId();
        Integer sOpenReferralsCount = 0;
        Set<Referral__c> lstOpenReferrals =  new Set<Referral__c>();
        String sUserWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedUser;
        Map<String, String> mapUserQueryParameters = new Map<String, String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sUserWhereClause);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        String userQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User','LastLoginDate,ContactId,IsOnboardTrainingDone__c', mapUserQueryParameters); 
        List<User> lstloggedInUser = Database.query(userQuery);
        Boolean bisOnboardTrainingDone = lstloggedInUser[0].IsOnboardTrainingDone__c;
            Id userContactId;
            if(UserInfo.getUserType() != RE_GlobalConstants.GUEST)
                userContactId= lstloggedInUser[0].ContactId;
            String sContactWhereClause = RE_DataBaseQueryFields.sWhereClauseGetLoggedContact;
            String sContactSafeQuery;
            Map<String, String> mapContactQueryParameters = new Map<String, String>();            
            mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sContactWhereClause);
            mapContactQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            Boolean bisUserFirstLogin;
            
            
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
            if(UserInfo.getUserType() == RE_GlobalConstants.GUEST){
                bisUserFirstLogin = false;
            }
            Integer iDraftCount = 0;
            if(loggedInUser == RE_GlobalConstants.strCitizenAppRole){
               //Changed the SOQL attributes for perf issues
                // List<Referral__c> lstReferrals = RE_SharingByPassCtrl.getReferralDetails(userContactId);
               List<Referral__c> lstReferrals = RE_SharingByPassCtrl.getReferralcountforPlan(userContactId);
               
                for(Referral__c objReferral :lstReferrals){
                    if(objReferral.Status__c != RE_GlobalConstants.REFERRAL_STATUS_CLOSED){
                        lstOpenReferrals.add(objReferral);
                    }
                    //Added to remove the extra SOQL for perf issue
                    if(objReferral.Status__c == RE_GlobalConstants.REFERRAL_STATUS_DRAFT){
                        iDraftCount++;
                    } 
                }
                sOpenReferralsCount = (lstOpenReferrals != null) ? lstOpenReferrals.size() : 0; 
                mapResponse.put('isResidentUser', true);
            }
            
            if(loggedInUser == RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN || loggedInUser == RE_GlobalConstants.COMMUNITY_PARTNER_STAFF){
                mapResponse.put('isCpUser', true);
            }
            if(loggedInUser == RE_GlobalConstants.CASE_WORKER_SUPERVISOR || loggedInUser == RE_GlobalConstants.CASE_WORKER){
                mapResponse.put('isAgencyUser', true);
                bisUserFirstLogin = true;
            }
            if(loggedInUser == RE_GlobalConstants.ASSISTER){
                mapResponse.put('isAssisterUser', true);
            }
            mapResponse.put('isGuestUser', bGuestUser);
            mapResponse.put('isUserFirstLogin', bisUserFirstLogin);
            //LMS Screen issue - Payal Dubela
            mapResponse.put('isCPOnboardingTrainingDone', bisOnboardTrainingDone);
            //Added to remove the extra SOQL for perf issue
            //mapResponse.put('draftReferralCount', RE_MyPlanCtrl.getDraftReferralCount());
           if (UserInfo.getUserType() != RE_GlobalConstants.GUEST_USERTYPE) {
               mapResponse.put('draftReferralCount', RE_SharingByPassCtrl.getCountValue(null));
           }
            mapResponse.put('sOpenReferralsCount', sOpenReferralsCount);
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
            errorMap.put('error',ex.getMessage());
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
    public static RE_CreateLightningServerResponse fetchKogURL(){
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>(); 
        Long startTime= DateTime.now().getTime();
        KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG Citizen');
        String strGateWayServiceRequestData;
        try{
            //callout to KOG to fetch the context Id
            strGateWayServiceRequestData = '[Input Parameters : pageURL='+objKog.PageURL__c+', ApplicationName='+objKog.ApplicationName__c+', Role='+objKog.Role__c+']';
            string contextId = RE_KOGRegistration.getKogContextID();
            if(String.isEmpty(contextId)){
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                publishEvents.add(new ErrorLog__e(StackTrace__c = '', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                                  ErroLog__c= 'Null response from Gateway Service', Source__c ='RE_ThemeCtrl', 
                                                  Message__c =  '' ,SourceFunction__c = 'fetchKogURL',
                                                  EndPoint__c = objKog.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,
                                                  Integration_Payload__c = strGateWayServiceRequestData,InterfaceName__c = 'Gateway Service',ResponseData__c = contextId));
                if(publishEvents.size()>0){
                    EventBus.publish(publishEvents);
                } 
            }
            String kogInitialURL = objKog.KOG_Registration_URL__c;
            String KogRegistartionURL = objKog.KOG_URL__c+contextId;
            String encodeRegistrationURL = kogInitialURL+EncodingUtil.urlEncode(KogRegistartionURL, 'UTF-8');
            mapResponse.put('KogRegistrationURL', encodeRegistrationURL);
            mapResponse.put('KogLoginURL', objKog.Kog_Login_URL__c);
        }catch(exception ex){
            errorMap.put('error',ex.getMessage());
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
    * @author       Venkat Korra
    * @date         12/16/2019
    * @methodname   getGuestHelpVideos()
    * @description  Used to get help videos for guest
    * @return       
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getGuestHelpVideos(String audience)
    { 
        //SOQL Injection Changes - Payal Dubela - 08/26
        audience= String.isNotBlank(audience)?String.escapeSingleQuotes(audience):audience;
        Boolean bSuccess = false;        
        Map<String, Object> mapResponse = new Map<String, Object>();
        Map<String, Object> errorMap = new Map<String, Object>();
        
        
        try
        {
                String userType = UserInfo.getUserType();
                if (audience != null && userType == 'Guest' && audience == 'Guest') { 
                List<scormanywhere__Course__c> courseList = new List<scormanywhere__Course__c>([SELECT Id, Audience__c, Name, Guest_Video_URL__c, Public_URL__c, scormanywhere__Status__c 
                                                                                                FROM scormanywhere__Course__c
                                                                                                WHERE Audience__c = :audience AND scormanywhere__Status__c =: 'Active']);
                if(courseList != null && courseList.size() > 0)
                {
                    mapResponse.put('courseList', courseList);
                    bSuccess = true;
                }
                }
                else{
                     bSuccess = true;
            }
        }catch(exception ex)
        {
            errorMap.put('error',ex.getMessage());
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);    
    }
    /*****************************************************************************************************
        * @author        Sri Putta
        * @date          08/13/2020
        * @methodname    roleChange()
        * @description   This method is to update user when role of the user changes
    *******************************************************************************************************/
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
             //Kojashree SCA Fix
              User u = new User();
              if(User.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.User.fields.RE_Selected_Role__c.isAccessible()){
                  u  =[Select id,RE_Selected_Role__c from User where id=:uId];
              }
         
              if(newRole.equalsIgnoreCase('Citizen')){//[Suresh] handle Citizen api 
                 u.RE_Selected_Role__c='Citizen_Individual';
             }
            else if(newRole.equalsIgnoreCase('kynector')){
                  u.RE_Selected_Role__c='Assister';
             }
             else{
                 u.RE_Selected_Role__c=newRole;
             }
                 //Kojashree SCA Fix
             if(Schema.sObjectType.User.isUpdateable()){
                 update u;
             }
             
             roles.add(newRole);
             roles.add(loggedInUserSelectedRole);
             //GeneralUtility.assignPS(roles); - [Suresh] on page load we are activating
             }
         }
         catch(exception ex){
            errorMap.put('error',ex.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ThemeCtrl','roleChange','Error Occured:: '+ ex.getMessage(), true);
        }
     }
}
