/*
* classname     : SSP_RoleSelection
* @description  : This class is used to assign new role permission set and revoke older role permission set if any. Made Without Sharing as it does all the permission set activation and deactivations.
* @date         : 15/04/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* 
*/
public without sharing class SSP_RoleSelection {

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         04/30/2020
    * @methodname   invokeFlowForPermissionSet
    * @description  This methods is used to set permission set  - CD2 4.1.2 Multiple Roles
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse invokeFlowForPermissionSet(String roleName, User loggedInUser,Boolean isRedirectedForImpersonation){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            if(isRedirectedForImpersonation==null)
            {
                isRedirectedForImpersonation=false;
            }
            loggedInUser = loggedInUser != null ? loggedInUser : SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                            new Set<String>{'Id', 'ContactId','SelectedRole__c','ApplicableRoles__c', 'LastVisitedNonCitizenRole__c','ShowCitizenDashboard__c'}, 
                                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getUserId()})[0]; 
            String assignedPermissionSets = ''; 
            /* #379715 */
            Map<String, String> roleAPIToPermissionSetMap = new Map<String, String>{
                SSP_GlobalConstants.ELIGIBILITY_BENEFIT_ROLE_API => SSP_GlobalConstants.ELIGIBILITY_BENEFIT_PERMISSION_SET_API 
            };

            Map<String, String> permissionSetToRoleAPIMap = new Map<String, String>{
                SSP_GlobalConstants.ELIGIBILITY_BENEFIT_PERMISSION_SET_API => SSP_GlobalConstants.ELIGIBILITY_BENEFIT_ROLE_API
            };

            roleName = roleAPIToPermissionSetMap.containsKey(roleName) ? roleAPIToPermissionSetMap.get(roleName) : roleName;             
            /** */
            
            // add roles to be activated
            Map<String, Object> params = new Map<String, Object>();
            if(roleName != null){
                params.put('listActivatePermissions', new List<String>{roleName}); 
            }
            
            //roles to be deactivated
            List<String> rolesTobeDeactivated = new List<String>();
            for(SessionPermSetActivation activeSets: [select id, PermissionSetId, permissionset.name, UserId, user.firstname, AuthSessionId 
                                                            from SessionPermSetActivation
                                                            where UserId = :Userinfo.getUserId()]){
                //Fix - Added check to make list elements unique - otherwise giving 101 SOQL exception
                if(!rolesTobeDeactivated.contains(activeSets.permissionset.name)){
                    rolesTobeDeactivated.add(activeSets.permissionset.name); 
                }                                                          
            }            
            //delete rolesTobeDeactivated;
            params.put('listDeactivatePermissions', (rolesTobeDeactivated != null && !rolesTobeDeactivated.isEmpty()) ? rolesTobeDeactivated : null);
            
            if(!test.isRunningTest() && !isRedirectedForImpersonation){
                Flow.Interview.Permission_Set_Activation_Flow PermissionSetFlow = new Flow.Interview.Permission_Set_Activation_Flow(params);
                PermissionSetFlow.start();
            }
            List<SessionPermSetActivation> lstPermissions = [select id, PermissionSetId, permissionset.name, UserId, user.firstname, AuthSessionId 
                                                            from SessionPermSetActivation
                                                            where UserId = :Userinfo.getUserId()];
            for(SessionPermSetActivation perm: lstPermissions){
                assignedPermissionSets = assignedPermissionSets +', '+perm.permissionset.name;
            }
            if(!String.isBlank(loggedInUser.LastVisitedNonCitizenRole__c) && loggedInUser.ApplicableRoles__c != null) {
                if(!loggedInUser.ApplicableRoles__c.contains(loggedInUser.LastVisitedNonCitizenRole__c)) {
                    loggedInUser.LastVisitedNonCitizenRole__c = '';
                }
            }
            //Updated selected and last visited Non Citizen Role on user
            if(String.isNotBlank(roleName)){ 
                User u = new User(Id = loggedInUser.Id);  
                roleName = permissionSetToRoleAPIMap.containsKey(roleName) ? permissionSetToRoleAPIMap.get(roleName) : roleName; //#379715 
                u.LastVisitedNonCitizenRole__c = String.isNotBlank(loggedInUser.SelectedRole__c) && !loggedInUser.SelectedRole__c.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE) && !roleName.equalsIgnoreCase(loggedInUser.SelectedRole__c) ? loggedInUser.SelectedRole__c : loggedInUser.LastVisitedNonCitizenRole__c;
                u.SelectedRole__c = roleName;       
                u.ShowCitizenDashboard__c =  String.isNotBlank(roleName) && roleName.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE) ? true : loggedInUser.ShowCitizenDashboard__c;
                u.ImpersonatedIndividualId__c = '';                
                //ESAPI.accessController().updateAsUser(u, new List<String>{'LastVisitedNonCitizenRole__c', 'SelectedRole__c', 'ShowCitizenDashboard__c', 'ImpersonatedIndividualId__c'});
                update u;
            }

            //add the programs based on selected role to session cache
            SSP_Utility.setProgramPermissions();
            
            //Set the selected role in session cache
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME); 
            String prevRole = (sessionPart != null && sessionPart.contains('selectedrole')) ? (String) sessionPart.get('selectedrole') : null;
            sessionPart.put(SSP_GlobalConstants.SELECTED_ROLE, roleName,7200);
            
            response.put('assignedPermissionSets', assignedPermissionSets+ '    ' +JSON.serialize(params)+ ' ' +SSP_Utility.getAvailableProgramsByRole());
            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RoleSelection', 'invokeFlowForPermissionSet', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);  
        }
        return response;
                       
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         04/30/2020
    * @methodname   getRequiredDetails
    * @description  This methods is used to fetch required data for role selection cmp - CD2 4.1.2 Multiple Roles
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse getRequiredDetails(String encryptedText,String token){
        SSP_LightningResponse response = new SSP_LightningResponse();
        Contact contactInfo = new Contact();
        try{
            if(String.isNotBlank(encryptedText)){
                contactInfo = decrypt(encryptedText);
            }            
            else if(String.isNotBlank(token) && !token.Equals('null')){
                contactInfo=SSP_NonCitizenDashboardService.redirectToIndividualDashboard(token);
            }
           
            if(contactInfo != null && (String.isNotBlank(encryptedText) || (String.isNotBlank(token)) && !token.Equals('null')) ){
                response.put('conWrap',JSON.serialize(contactInfo));
                SSP_DashboardService.isRedirectedForImpersonation= true;
            } 
            response.put('detailsWrap', SSP_DashboardService.constructDetailsWrapper(UserInfo.getUserId(), true));
            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RoleSelection', 'getRequiredDetails', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);  
        }
        return response;
    }  
    
    @AuraEnabled
    public static SSP_LightningResponse impersonateCitizenOnLoad(String contactJson){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            Contact contactInfo = (Contact)JSON.deserialize(contactJson,Contact.class);
            if(contactInfo != null){
                SSP_NonCitizenDashboardController.impersonateCitizen(contactInfo);
                response.bIsSuccess = true;
            }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RoleSelection', 'getRequiredDetails', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);  
        }
        return response;
    }

    /***************************************************************************************************
    * @author       Shrikant Raut
    * @date         05/27/2020
    * @methodname   resetDashboardRefreshFlag
    * @description  This methods is used to reset dashboard refresh flan for non citizen
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse resetDashboardRefreshFlag(){
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            sessionPart.remove(SSP_GlobalConstants.INDIVIDUAL_ID);
            User loggedInUser = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                            new Set<String>{'Id', 'ContactId'}, 
                                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getUserId()})[0]; 
            Contact currentUserCon = new Contact(Id = loggedInUser.ContactId);         
            currentUserCon.IsDashboardRefreshNeeded__c = true;            
            ESAPI.accessController().updateAsUser(new Map<ID,Contact>{currentUserCon.Id => currentUserCon}, new List<String>{'IsDashboardRefreshNeeded__c'});
            response.bIsSuccess = true;
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RoleSelection', 'resetDashboardRefreshFlag', ex.getMessage(), true);
            response.addException(ex, lstLogMessages[0].Id);  
        }
        return response;
    }
    /***************************************************************************************************
    * @author       Keshav Poduval
    * @date         07/30/2020
    * @methodname   decrypt
    * @description  This methods is used to decrypt the url parameter sent from agent portal
    * @return       Contact
    *****************************************************************************************************/
    @AuraEnabled
    public static Contact decrypt(string encryptedText)
    {
        blob key =Blob.valueof(String.valueOf(EncryptionDecryptionSettings__c.getValues('SSPKey').get('key__c')));
        //blob iv = EncodingUtil.base64Decode('');
        Blob encryptedData = EncodingUtil.base64Decode(encryptedText.substring(0, encryptedText.length()));
        blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, encryptedData);//Crypto.decrypt('AES256', key, iv, encryptedData);
        return updateRoleName(decryptedData.toString());
        //return decryptedData.toString();	
    }

    /***************************************************************************************************
    * @author       Keshav Poduval
    * @date         07/30/2020
    * @methodname   decrypt
    * @description  This method update Role sent by Agent Portal on login
    * @return       Contact
    *****************************************************************************************************/
    public static Contact updateRoleName(String decryptedData){
        Contact con= new Contact();
        
        Map<String,String> mapParams = (Map<String,String>) JSON.deserialize(decryptedData,Map<String,String>.class);
        
        List<User> loggedInUser = SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                     new Set<String>{'Id', 'SelectedRole__c','Profile.Name'}, 
                                                                     new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
        User userDetail = loggedInUser[0];
        //roleId, customerId, doiAgentId, customerid, applicationnumber, casenumber and individualid
        if(mapParams.containsKey('roleId') && mapParams.get('roleId') != null){
            String roleId = 'R'+mapParams.get('roleId');
            SSP_RoleIdentifier__mdt roleName = [Select Id, DeveloperName,RoleId__c from SSP_RoleIdentifier__mdt WHERE RoleId__c = :roleId];
            userDetail.SelectedRole__c = roleName.DeveloperName;
            
        }
        
        
        SSP_GenericDMLHelper.updateRecords(new List<User>{userDetail},new List<String>{'SelectedRole__c'});
        
        if(mapParams.containsKey('IndividualId') && mapParams.get('IndividualId') != null){
            //userDetail.ImpersonatedIndividualId__c = mapParams.get('individualid');
            System.debug('Inside individualId component');
            con.FirstName=mapParams.get('firstName');
            con.LastName=mapParams.get('lastName');
            con.GenderCode__c=mapParams.get('gender');
            con.IndividualId__c=mapParams.get('IndividualId');
            con.SuffixCode__c = mapParams.get('suffix');
            con.MiddleName = mapParams.get('middleInitial');
            
        }

        return con;
    }
}