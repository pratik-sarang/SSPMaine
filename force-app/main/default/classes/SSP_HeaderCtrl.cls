/*
* classname     :  SSP_HeaderCtrl
* @description  :  Class to get Header Info
* @author       :  Varun Kochar   
* @date         :  28/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_HeaderCtrl {
    /***************************************************************************************************
    * @author       Varun Kochar
    * @date         04/02/2020
    * @methodname   getLoggedInUserInfo
    * @description  This methods is used to get logged in user language
    * @return       
    *****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse getLoggedInUserInfo(){
        try{
            SSP_LightningResponse objResponse = new SSP_LightningResponse();
            String userRole = SSP_Utility.getSelectedRole(); //#392529
            objResponse.put('userRole', userRole); //#392529
            if(UserInfo.getUserType() != 'Guest'){
                objResponse.put('wrapper', UserInfo.getLanguage());
            }
            else{
                objResponse.put('wrapper', '');
            }
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                String selectedRole =(sessionPart != null && sessionPart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionPart.get(SSP_GlobalConstants.SELECTED_ROLE)) :String.valueOf(sessionPart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
            
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('REPS_Home',selectedRole);          
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible'){
                objResponse.put('showRepsLink',true);
            }                
            try{
                /**Added by Shrikant - CD2 - 4.2.1	Client View Banner */
                SSP_DashboardService.UserDetailsWrapper userWrapper = SSP_DashboardService.constructDetailsWrapper(UserInfo.getUserId(), false);
                if(userWrapper != null && String.isNotBlank(userWrapper.impersonatedIndividualId)){
                    String individualId = SSP_Utility.getIndividualId();                   
                    /** #385168 */
                    Contact citizenContact = SSP_DashboardService.getIndividualContact(individualId);            
                    if(citizenContact != null && String.isNotBlank(citizenContact.Id)){
                    List<SSP_Member__c> memberList = SSP_DashboardService.getMemberDetails(new Map<String, String>{'Contact__c'=>  citizenContact.Id}); 
                    if(memberList != null && !memberList.isEmpty()){
                        citizenContact.FirstName = String.isNotBlank(memberList[0].FirstName__c) ? memberList[0].FirstName__c : citizenContact.FirstName;
                        citizenContact.MiddleName = String.isNotBlank(memberList[0].MiddleInitial__c) ? memberList[0].MiddleInitial__c : citizenContact.MiddleName;
                        citizenContact.LastName = String.isNotBlank(memberList[0].LastName__c) ? memberList[0].LastName__c : citizenContact.LastName;
                        citizenContact.SuffixCode__c = String.isNotBlank(memberList[0].SuffixCode__c) ? memberList[0].SuffixCode__c : citizenContact.Suffix;
                    }
                    }
                    userWrapper.citizenContact = citizenContact;
                    /** */
                }
                objResponse.put('userDetails', userWrapper); 
                    /**For Message Center Role Based Rendering */
                // String selectedRole = SSP_Utility.getSelectedRole();
                    String primaryIndvID = ssp_utility.getIndividualId();
                    //for Impersonization
                    if(selectedRole!=SSP_GlobalConstants.CITIZEN_ROLE && primaryIndvID!=null && primaryIndvID!=''){
                        Set<string> noMsgCenterAccessRoles = new Set<String>{'QE_Hospital','QE_Pregnancy','DJJ_Representative','Eligibility_&_Benefit_Inquiry_User','Department_Of_Education_Representative'};
                        if(noMsgCenterAccessRoles.contains(selectedRole)){
                            objResponse.put('hideMessageCenter',true);
                        }
                        else{
                            objResponse.put('hideMessageCenter',false);
                        }
                    }else{
                        objResponse.put('hideMessageCenter',false);
                    }
	        }catch(Exception ex){
	            LOG_LogMessageUtility.logMessage(ex, 'SSP_HeaderCtrl', 'getLoggedInUserInfo', ex.getMessage(), true);
	        }
            }
            /** #390435 */
            objResponse = SSP_Utility.constructSecurityWrap(objResponse, new Map<String, String>{
                                                                        'securityMatrixNavigation'=>'SSP_APP_ClientNavigations', 
                                                                        'securityMatrixMyInformation'=>SSP_GlobalConstants.MY_INFORMATION_LANDING_SCREENID});
            /** */
            return objResponse;
        }catch(Exception e){
    		LOG_LogMessageUtility.logMessage(e, 'SSP_HeaderCtrl', 'getLoggedInUserInf', e.getMessage(), true);
        }
        return null;
    }


    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         06/23/2020
    * @methodname   getVerticalMenuDetails
    * @description  This methods is to get details for VerticalMenuList
    * @return       
	*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getVerticalMenuDetails(){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            SSP_LightningResponse validateSSORes = SSP_Utility.validateSSORedirect('CLAIMS');
            if(validateSSORes != null && validateSSORes.mapResponse.containsKey('endPoint') && validateSSORes.mapResponse.containskey('encryptedToken')) {
                response.put('claimsSSORedirectOn', true);
            }
            response.put('userDetails', SSP_Utility.getUserDetails(UserInfo.getUserId()));
            response.put('securityMatrixNavigation', SSP_Utility.getScreenAccessDetails('SSP_APP_ClientNavigations', null));
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HeaderCtrl', 'returnToNonCitizenDashboard', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);  
        }
        return response;
    }


    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         05/21/2020
    * @methodname   returnToNonCitizenDasboard
    * @description  This methods is to update current user record with details req to navigate to non citizen dashboard - CD2 4.2.1	Client View Banner
    * @return       
	*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse returnToNonCitizenDashboard(){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            User toBeUpdated =  SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                            new Set<String>{'Id', 'LastVisitedNonCitizenRole__c','ShowCitizenDashboard__c','SelectedRole__c'}, 
                                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getUserId()})[0]; 
            toBeUpdated.ShowCitizenDashboard__c = false;
            list<String> waiverRoles = new list<String>{
                'APPLICATION_INITIATOR',
                'APPLICATION_REVIEWER',
                'CASE_MANAGEMENT_ADMINISTRATOR_INTERNAL',
                'WAIVER_CAPACITY_REVIEWER',
                'CASE_MANAGER',
'CASE_MANAGER_IN_TRAINING',//387455
                'CASE_SUPERVISOR',
                'CHFS_APPLICATION_INITIATOR',
                'LEVEL_OF_CARE_ASSESSOR',
                'LOC_REVIEWER',
                'POC_REVIEWER',
                'SERVICE_NEEDS_ASSESSOR',
                'INTERNAL_LOC_ASSESSOR',
                'WAIVER_DIRECT_SERVICE_PROVIDER',
                'WAIVER_DIRECT_SERVICE_PROVIDER_SUPERVISOR',
		'CAPACITY_MANAGEMENT_ADMINISTRATOR',
		'Case_Management_Administrator_Read_Only', //386177
		'PROD_Support_Read_Only', //386177
		'CHFS_Internal_Reviewer' //386177
            };
            if(toBeUpdated.SelectedRole__c.equals('Insurance_Agent')){
        	response.put('userRole',toBeUpdated.SelectedRole__c);
                toBeUpdated.SelectedRole__c = toBeUpdated.LastVisitedNonCitizenRole__c;
                response.put('redirectToAgentPortal',true);

            }
            else if(waiverRoles.contains(toBeUpdated.SelectedRole__c)){
        	response.put('userRole',toBeUpdated.SelectedRole__c);
                toBeUpdated.SelectedRole__c = toBeUpdated.LastVisitedNonCitizenRole__c;
                response.put('redirectToWaiverPortal',true);
            }
            toBeUpdated.ImpersonatedIndividualId__c = '';
            SSP_GenericDMLHelper.updateRecords(new list<User>{toBeUpdated}, new List<String>{'ShowCitizenDashboard__c', 'ImpersonatedIndividualId__c','SelectedRole__c'});

            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            if(String.isNotBlank(toBeUpdated.LastVisitedNonCitizenRole__c) && 'Citizen_Individual'.equals(toBeUpdated.SelectedRole__c)){
                sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE,toBeUpdated.LastVisitedNonCitizenRole__c,7200);
            }
            sessionPart.remove(SSP_GlobalConstants.INDIVIDUAL_ID);
            sessionPart.remove('removedProgram');
            sessionPart.remove('EnrolledMedicaidPrograms');
            sessionPart.remove('NonEnrolledMedicaidPrograms');
            sessionPart.remove('hasKihippProgram');
            sessionPart.remove('AllBenefits');
            sessionPart.remove('ActiveBenefits');
            sessionPart.remove('PendingInterviewBenefits');
            sessionPart.remove('PendingVerificationBenefits');
            sessionPart.remove('hasBenefits');
            sessionPart.remove('contactName');
            sessionPart.remove('isCaseInChangeMode');
            sessionPart.remove('caseOwnership');
            sessionPart.remove('isTeamMember');
            sessionPart.remove('hasAuthRepAgents');
            sessionPart.remove('hasMedicaidRenewals');
            sessionPart.remove('hasOtherRenewals');
            sessionPart.remove('hasActiveCase');
            sessionPart.remove('notificationsList');
            sessionPart.remove('caseVsHOH');
            sessionPart.remove('caseOptions');
            sessionPart.remove('caseVsStatus');
            sessionPart.remove('isExistingUser');
            sessionPart.remove('isHeadOfHouseHold');

            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HeaderCtrl', 'returnToNonCitizenDashboard', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);  
        }
        return response;
    }
    
    /***************************************************************************************************
* @author       Varun Kochar
* @date         04/02/2020
* @methodname   updateUserLanguage
* @description  This methods is used to update user language
* @return       
*****************************************************************************************************/
    @auraEnabled
    public static void updateUserLanguage(String selectedLanguage){
	//SSP_Utility.isAuthenticatedUser();
        try{ 
    List<User> userlist=SSP_UserSelector.queryUserData(
            new Map<String, String>{'objectName'=>'User'},
            new Set<String>{'Id','ContactId','ImpersonatedIndividualId__c'},
            new Map<String, String>{'Id'=> UserInfo.getUserId()}
        );
        if(userlist!=null &&userlist.size()>0&&userlist[0].ImpersonatedIndividualId__c!=null)
        {
            List<Contact>listcontact = SSP_ContactSelector.queryContactData (
            new Map<String, String>{'objectName'=>'Contact'},
            new Set<String>{'Id','CacheBenefitMedicaidEBTData__c'},
            new Map<String, String>{'IndividualId__c'=> userlist[0].ImpersonatedIndividualId__c});
            if(listcontact!=null&& listcontact.size()>0)
            {
            SSP_ProgramSelectionService.resetDashboardRefreshFlag (listcontact[0].Id);

            }
        }
            Id ContactId = SSP_Utility.getCurrentUserDetails()[0].ContactId;
            SSP_ProgramSelectionService.resetDashboardRefreshFlag (ContactId);
            User userObj = new User(Id = UserInfo.getUserId() , LanguageLocaleKey = selectedLanguage);
            ESAPI.accessController().updateAsUser(userObj, SSP_Utility.getFieldsNamesList(new List<User>{userObj}));
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HeaderCtrl', 'updateUserLanguage', e.getMessage(), true);
        }
    }
        /***************************************************************************************************
* @author       Kommana Lova Durga Prasad
* @date         04/12/2020
* @methodname   fetchKogURL
* @description  This methods is used to fetch the KOG Login URL
* @return       
*****************************************************************************************************/
    
     @auraEnabled
    public static SSP_LightningResponse fetchKogURL(string selectedRole){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try{
            KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG SSP Citizen');
            string contextId = '';
            if(string.isNotBlank(selectedRole)){
                 contextId = SSP_KOGRegistration.getKogContextID(selectedRole);
            }
            String KogRegistartionURL = objKog.KOG_URL__c+contextId;
            objResponse.put('KogRegistrationURL', KogRegistartionURL);
            string KogLoginURL = string.isNotBlank(objKog.Kog_Login_URL__c) ? objKog.Kog_Login_URL__c : '/'+AppConfig__c.getInstance('BenefindPrefix').value__c+'/s/login';
            objResponse.put('KogLoginURL', KogLoginURL);
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_GetInterpreterModalCtrl', 'getGetInterpreterModalDetail', e.getMessage(), true);
            objResponse.put('error', e.getMessage());
        }
        return objResponse;
    }
    

/***************************************************************************************************
* @author       Shivam Tiwari
* @date         05/07/2020
* @methodname   getHOHFlag
* @description  This methods is used to get Member Type field value from Contact record of logged in user 
* @return       
*****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getHOHFlag(){
        List<User> userList = new List<User>();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                      new Set<String>{'Id', 'ContactId','Contact.IndividualId__c', 'Contact.MemberType__c', 'Contact.CaseOwnership__c','Contact.Name'}, 
                                                      new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
            
            if(userList != null && userList.size() > 0){
                toSend.put('memberType', userList[0].Contact.MemberType__c);
                toSend.put('ownerType', userList[0].Contact.CaseOwnership__c);
            }            
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HeaderCtrl', 'getHOHFlag', e.getMessage(), true);
        }
        return toSend;
    }


/***************************************************************************************************
* @author       Shivam Tiwari
* @date         05/14/2020
* @methodname   getHOHFlag
* @description  This methods is used to update Member Type field value on Contact record of logged in user 
* @return       
*****************************************************************************************************/
    @AuraEnabled
    public static void updateMemberTypeOnContact(Boolean isHeadOfHousehold){
        SSP_Utility.isAuthenticatedUser();
        try {
            List<User> userList = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                            new Set<String>{'Id', 'ContactId','Contact.IndividualId__c', 'Contact.MemberType__c', 'Contact.CaseOwnership__c','Contact.Name'}, 
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});

            if(userList != null && userList.size() > 0){
                List<Contact> conList = new List<Contact>();
                if(isHeadOfHousehold == true){
                    if(userList[0].Contact.MemberType__c == null){
                        userList[0].Contact.MemberType__c = SSP_GlobalConstants.HOH;
                    }
                    else{
                        userList[0].Contact.MemberType__c = ((userList[0].Contact.MemberType__c) != null && (userList[0].Contact.MemberType__c).contains(SSP_GlobalConstants.HOH)) ? (userList[0].Contact.MemberType__c) : (userList[0].Contact.MemberType__c) + ' ' + SSP_GlobalConstants.HOH;
                    }
                }
                else {
                    if(userList[0].Contact.MemberType__c == null){
                        userList[0].Contact.MemberType__c = SSP_GlobalConstants.DEP;
                    }
                    else{
                        userList[0].Contact.MemberType__c = ((userList[0].Contact.MemberType__c) != null && (userList[0].Contact.MemberType__c).contains(SSP_GlobalConstants.DEP)) ? (userList[0].Contact.MemberType__c) : (userList[0].Contact.MemberType__c) + ' ' + SSP_GlobalConstants.DEP;
                    }
                }
                conList.add(userList[0].Contact);
                if(conList.size() > 0){
                    ESAPI.accessController().updateAsUser(new Map<ID,Contact>(conList), SSP_Utility.getFieldsNamesList(conList));
                }
            }
        }
        catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_HeaderCtrl', 'updateMemberTypeOnContact', e.getMessage(), true);
        }
    }
    
}