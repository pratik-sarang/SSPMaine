/**
* Class Name    : RE_UserCreationHelper
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Hepler class for creating user
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description           RE_UserControllerTest                                              
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  PANKAJ       Initial Version
**/
public with sharing class RE_UserCreationHelper {
    
  
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   assignPermissionSetOnCreate()
    * @param        Set<ID>    setUserIds      : User Ids
    * @description  This methods is used to assign permissionset when a user is created in the system
    * @return       void
    ***********************************************************************************************************/
    @future
    public static void assignPermissionSetOnCreate(Set<ID> setUserIds) {
        assignPermissionSet(setUserIds);
    }
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   assignPermissionSet()
    * @param        Set<ID>    setUserIds      : User Ids
    * @description  This methods is used to assign permissionset
    * @return       void
    ***********************************************************************************************************/
    public static void assignPermissionSet(Set<ID> setUserIds) {
        List<User>  lstUsers;
        String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUser;
        String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserSetId; 
        Map<String,String> mapUserQueryParameters = new Map<String,String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
        String sUserQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User', sFieldsToQueryOnUser, mapUserQueryParameters);
        if(sUserQuery != null){
            lstUsers = Database.query(sUserQuery);
        }else{
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCreationHelper.class.getName(), 'assignPermissionSet', RE_GlobalConstants.FLS_ERROR, true);
        }
        List<PermissionSetAssignment> lstPermissionRecords = new List<PermissionSetAssignment>();
        List<String> lstPermissionSetNames = new List<String>();
        //lstPermissionSetNames.add('RE Community Partner Admin');
        //lstPermissionSetNames.add('RE Community Partner Staff');
        if(Test.isRunningTest()){
        	lstPermissionSetNames.add('RE Permission Set For Test Classes');
        }
        
        String sFieldsToQueryOnPermissionSet = RE_DataBaseQueryFields.sFieldsToQueryOnPermissionSet;
        String sWhereClauseOnPermissionSet = RE_DataBaseQueryFields.sWhereClauseOnPermissionSet;
        Map<String,String> mapQueryOnPermissionSet = new Map<String,String>();
        mapQueryOnPermissionSet.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnPermissionSet);
        String sPermissionSetQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('PermissionSet', sFieldsToQueryOnPermissionSet, mapQueryOnPermissionSet);
        Map<Id, PermissionSet> lstPermissionSetRecords = new Map<Id, PermissionSet>(); 
        List<PermissionSet> lstPermissionSet = Database.query(sPermissionSetQuery);
        for(PermissionSet objPermissionSet : lstPermissionSet){
            lstPermissionSetRecords.put(objPermissionSet.Id, objPermissionSet);
        }
        
        Map<String, PermissionSet> mapPermissionSets = new Map<String, PermissionSet>();
        // map constructs <'Staff', map<'RE_AdminProfile',List<PermissionSet>>
        Map<String, Map<String, List<String>>> mapRolePermissions = getCommunityUserCofig();
        for (Id objId : lstPermissionSetRecords.keySet()) {
            PermissionSet objPermission = lstPermissionSetRecords.get(objId);
            mapPermissionSets.put(objPermission.Label, objPermission);
        }
        for (User objUser : lstUsers) {
            Map<String, List<String>> mapPofileNamePermissionsSet = mapRolePermissions.get(objUser.Contact.PermissionsLevel__c);
            List<String> lstPermissionsSetLabels = mapPofileNamePermissionsSet.get(objUser.Profile.Name);
            for (String permissionSetName : lstPermissionsSetLabels) {
               if(mapPermissionSets.containskey(permissionSetName)){
                    Id permissionSetId = mapPermissionSets.get(permissionSetName).Id;
                    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = objUser.Id);
                    lstPermissionRecords.add(psa);
               }
            }
        }
		//IronDome  Fix - Suresh
            if (lstPermissionRecords != null && lstPermissionRecords.size() > 0) {
                try {
                    RE_DataAccessChecker.insertSetUpObjects(PermissionSetAssignment.getSObjectType(), lstPermissionRecords);
                } catch (Exception e) {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserCreationHelper','AssignPermissionSet', e.getMessage(),false);
                }
            }
        }
    
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   RemovePermissionSet()
    * @param        Set<ID>    setUserIds      : User Ids
    * @description  This methods is used to remove the permissionset
    * @return       void
    ***********************************************************************************************************/
    @future   
    public static void removePermissionSet(Set<ID> setUserIds){
        List<User> lstUsers;
        String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUser;
        String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUserSetId;
        Map<String,String> mapUserQueryParameters = new Map<String,String>();
        mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
        mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        String sPermissionSetQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User', sFieldsToQueryOnUser, mapUserQueryParameters);
        if(sPermissionSetQuery != null){
            lstUsers = Database.query(sPermissionSetQuery);
        }
        List<String> lstPermissionSetNames = new List<String>();
        lstPermissionSetNames.add('RE Community Partner Admin');
        lstPermissionSetNames.add('RE Community Partner Staff');
        String sFieldsToQueryOnPermissionSetAssignment = RE_DataBaseQueryFields.sFieldsToQueryOnPermissionSetAssignment;
        String sWhereClauseOnPermissionSetAssignment = RE_DataBaseQueryFields.sWhereClauseOnPermissionSetAssignment;
        Map<String,String> mapUserQueryOnPermissionSetAssignment = new Map<String,String>();
        mapUserQueryOnPermissionSetAssignment.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnPermissionSetAssignment);
        String sUserQueryOnPermissionSetAssignment = RE_DataAccessChecker.getQueryStringforSetupObjects('PermissionSetAssignment', sFieldsToQueryOnPermissionSetAssignment, mapUserQueryOnPermissionSetAssignment);
        
        List<PermissionSetAssignment> lstTobeDeleted = Database.query(sUserQueryOnPermissionSetAssignment);
        //Force Reviewer Changes - Payal Dubela - 08/28
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeylstToDel = (lstTobeDeleted != null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
        switch on (switchCaseKeylstToDel) {
         when SWITCH_SUCCESS {  
            try{
                Database.DeleteResult[] drList = RE_DataAccessChecker.deleteSetUpObjects(PermissionSetAssignment.getSObjectType(), lstTobeDeleted);
				boolean isSuccess = false;// Force Reviewer Fix - Suresh
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
						isSuccess = true;
                    }
                }
				if(isSuccess){
                        assignPermissionSet(setUserIds);
                    }
            } catch (Exception e) {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_UserCreationHelper','RemovePermissionSet',e.getMessage(),false); 
            }
         }
        }
    }
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         05/18/2019
    * @methodname   getCommunityUserCofig()
    * @description  This methods is used to get the Community Config metadata records
    * @return       Map<String, Map<String, List<String>>> : {'Admin' : {'CP User Admin':'['Permission1','Permission2']'}}
    ***********************************************************************************************************/
    public static Map<String, Map<String, List<String>>> getCommunityUserCofig(){
        List<RECommunityUsersConfiguration__mdt> lstUserConfig = GeneralUtility.getCommunityUsersSetting(null);
        Map<String, Map<String, List<String>>> mapRolePermissions = new Map<String, Map<String, List<String>>>();
        for(RECommunityUsersConfiguration__mdt obj : lstUserConfig){
            List<String> lstPermissions = (!String.isBlank(obj.PermissionSets__c)) ? (obj.PermissionSets__c).split(',') : null ;
            Map<String, List<String>> mapProfilePermission = new Map<String, List<String>>();
            mapProfilePermission.put(obj.ProfileName__c, lstPermissions);
            mapRolePermissions.put(obj.Role__c, mapProfilePermission);
        }
        return mapRolePermissions;
    }
    /*********************************************************************************************************
    * @author       Anuj Vashistha
    * @date         06/08/2019
    * @methodname   createContactUser()
    * @description  This methods is invoked by Process Builder to create a Contact Record for a Guest User after a new Cliam request is approved
    * 				by a State User
    * @return       void
    ***********************************************************************************************************/
    @InvocableMethod
    public static void createContactUser(List<String> lstParams){
        for (String sParam : lstParams) {
            try {
                List<String> listParams = sParam.split(RE_GlobalConstants.SEMICOLON_DELIMITER);
                if (listParams != null && !lstParams.isEmpty() && listParams.size() == 5) {
                    RE_UserWrapper objWrapper = new RE_UserWrapper();
                    objWrapper.FirstName = String.valueof(listParams[0]);
                    objWrapper.LastName = String.valueof(listParams[1]);
                    objWrapper.Email = String.valueof(listParams[2]);
                    objWrapper.Phone = String.valueof(listParams[3]);
                    String sUniqueId = String.valueof(listParams[4]);
                    Id AccountId = sUniqueId;
                    objWrapper.AccountId = AccountId;
                    objWrapper.bIsClaim = true;
                    objWrapper.Status = RE_GlobalConstants.USER_STATUS_ACTIVE;
                    objWrapper.PermissionsLevel = RE_GlobalConstants.str_RE_ADMIN_CONTACT_PERMISSION;
                    objWrapper.isClaimFlow=true;
                    RE_UserCtrl.upsertContact(objWrapper, false);
                }
                
            } catch (Exception e) {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_UserCreationHelper','createContactUser',e.getMessage(),false); 
            }
        }
    }
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         05/15/2019
    * @methodname   updateUserStatusToActive()
    * @description  This methods is used to create a user record
    * @param        contactId   (String) : Contact Id
    * @return       RE_CreateLightningServerResponse
    /***********************************************************************************************************/
    public static RE_CreateLightningServerResponse updateUserStatusToActive(String sContactId){
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        Boolean bSuccess = false;
        Set<ID> contactIDs = new Set<ID>();
        User objUser = new User();
        Contact con= new Contact();
        try{             
            String sFieldsToQueryOnContact = RE_DataBaseQueryFields.sFieldsToQueryOnContact;
            String sWhereClauseOnContact = RE_DataBaseQueryFields.sWhereClauseContactQuery;
            Map<String,String> mapContactQueryParameters = new Map<String,String>();
            mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnContact);
            mapContactQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
            
            Map<Boolean,String> mapConactResponse = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsToQueryOnContact, mapContactQueryParameters);
            RE_GlobalConstants.SWITCH_CONSTANTS switchContactKey = (mapConactResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
            switch on (switchContactKey) {
            when SWITCH_SUCCESS {
                String sContactQuery =  mapConactResponse.get(true);
                con=RE_SharingByPassCtrl.getContactDetails(sContactQuery,sContactId);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_UserCreationHelper','updateUserStatusToActive',RE_GlobalConstants.FLS_ERROR + '' + mapConactResponse.get(false), true);
            }
           }

            String roleName=con.PermissionsLevel__c==RE_GlobalConstants.ADMIN_ROLE?RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN:RE_GlobalConstants.COMMUNITY_PARTNER_STAFF;
            AccountContactRelation acr =RE_SharingByPassCtrl.getACRRecord(sContactId,roleName,false);
            Set<Id> setOfacrIds = new Set<Id>();
            if(acr != null && acr.IsActive==false){
                acr.IsActive=true; 
                RE_SharingByPassCtrl.updateObjects(AccountContactRelation.getSObjectType(),new List<AccountContactRelation>{acr});
            }
            contactIDs.add(sContactId);
            if(contactIDs.size() > 0){
                Database.executeBatch(new CPUserCreationBatch(contactIDs), 200);
            }
            mapResponse.put('status', objUser.isActive);
            bSuccess=true;
        }catch(Exception e){
            errorMap.put('error',e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserController','updateUserStatusToActive', e.getMessage(),false);
        }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /*********************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         05/15/2019
    * @methodname   updateUser()
    * @description  This methods is used to update a user record
    * @param        lstUser     List<User>        : List of User objects to be updated
    * @return       void
    /***********************************************************************************************************/
    public static Boolean updateUser(Map<User, String> mapUserRole){
        Boolean bIsSuccess = false;
        try {
            List<User> lstUserstobeUpdate = new List<User>();
            Map<String, Profile> mapProfiles = new Map<String, Profile>();
            String sFieldsToQueryOnProfile = RE_DataBaseQueryFields.sFieldsToQueryOnProfile;
            String sProfileQuery;
            Map<String,String> mapProfileQueryParameters = new Map<String,String>();
            mapProfileQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
            sProfileQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('Profile', sFieldsToQueryOnProfile, mapProfileQueryParameters); 
            List<Profile > lstProfiles = Database.query(sProfileQuery);
            
            for (Profile objProfile : lstProfiles) {
                mapProfiles.put(objProfile.Name, objProfile);
            }
            if (lstUserstobeUpdate != null) {
                bIsSuccess = RE_SharingByPassCtrl.updateUser(mapUserRole, mapProfiles);
            }
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_UserCreationHelper','updateUser',e.getMessage(),false);
            throw e;
        }
        return bIsSuccess;
    }
}