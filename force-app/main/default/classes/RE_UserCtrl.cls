/**
* Class Name    : RE_UserCtrl
* Owner         : DELOITTE
* Created Date  : 05/02/2019
* Description   : Controller class for RE_UserCtrl
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                          
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  PANKAJ       Initial Version
*  12/10/2019  PANKAJ       Changed logic for populating account and owner id as part of as part of defect#342580 & defect#339678
*  01/07/2020  PANKAJ       Added duplicate check as part of defect#341025
*  03/26/2020  SRIKANTH     Release_1.1 Role Management Service Integrations implementation
*  08/18/2020  Venkat       Changes related to RE Security Changes
*/
public with sharing class RE_UserCtrl {
    public class applicationException extends Exception {}
    /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   getWrapper()
    * @description  This methods is used to get the picklist values from given sObject
    * @param        sContactId           (String)   : contact record Id
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getWrapper(String strContactId){ 
        Map<String,String> mapInputs= new Map<String,String>();
        String sContactId;
        if(String.isNotBlank(strContactId)){
            sContactId=String.escapeSingleQuotes(strContactId);
        }
        else{
            sContactId = RE_GlobalConstants.sEmptyString;
        }
        String sAccountId=GeneralUtility.getLoggedInAccountId();
        Id loggedInUserId = UserInfo.getUserId();
        Map<Id,AccountContactRelation> acrMap=new Map<Id,AccountContactRelation>();
        GeneralUtility.isAuthenticatedUser();
        List<Location__c> lstLocation = new List<Location__c>();
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        List<User> usr= new List<User>();
        Boolean bSuccess = false;
        String sWrapperData;  
        String sLocationQuery;
        RE_UserWrapper objUserWrapper = new RE_UserWrapper();
        Id locationRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.strLocationObjectName, RE_GlobalConstants.LOCATION);
        String sFieldsToQueryOnLocation = RE_DataBaseQueryFields.sFieldsToQueryOnLocation;
        String sWhereClauseOnLocation = RE_DataBaseQueryFields.sWhereClauseOnLocation;
        Map<String,String> mapLocationQueryParameters = new Map<String,String>();
        mapLocationQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocation);
        mapLocationQueryParameters.put(RE_GlobalConstants.sLimitKey, Label.maxsoqlquerylimit);
        Map<Boolean,String> mapLocationQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocationObjectName, sFieldsToQueryOnLocation, mapLocationQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapLocationQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sLocationQuery =  mapLocationQueryResponse.get(true);
                lstLocation = Database.query(sLocationQuery); 
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCtrl.class.getName(), 'getWrapper', RE_GlobalConstants.FLS_ERROR + '' + mapLocationQueryResponse.get(false), true);
            }
        }
        if(!String.isBlank(sContactId)){
            try{
                // user query
                String sFieldsToQueryOnUser = RE_DataBaseQueryFields.sFieldsToQueryOnUser;
                String sWhereClauseOnUser = RE_DataBaseQueryFields.sWhereClauseOnUser;
                User objUserdata = new User();
                Contact objContact = new Contact();
                Map<String,String> mapUserQueryParameters = new Map<String,String>();
                mapUserQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnUser);
                mapUserQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                String sUserQuery = RE_DataAccessChecker.getQueryStringforSetupObjects('User', sFieldsToQueryOnUser, mapUserQueryParameters);
                usr=Database.query(sUserQuery);
                if(usr!=null && usr.size()>0){
                    objUserdata=usr[0];
                    objUserWrapper.userdata = usr[0];
                    objUserWrapper.isLoggedInUser=(loggedInUserId==objUserdata.Id)?true:false;
                }
                // contact query
                String sContactQuery;
                //RE Security Changes - Payal Dubela
                Id contactRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Contact',RE_GlobalConstants.strNonCitizenContactDevName);
                String sFieldsToQueryOnContact = RE_DataBaseQueryFields.sFieldsToQueryOnContact;
                String sWhereClauseOnContact = RE_DataBaseQueryFields.sWhereClauseOnContact;
                Map<String,String> mapContactQueryParameters = new Map<String,String>();
                mapContactQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnContact);
                mapContactQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                
                Map<Boolean,String> mapConactResponse = RE_DataAccessChecker.getFieldsAccessibility('Contact', sFieldsToQueryOnContact, mapContactQueryParameters);
                RE_GlobalConstants.SWITCH_CONSTANTS switchContactKey = (mapConactResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
                switch on (switchContactKey) {
                    when SWITCH_SUCCESS {
                        sContactQuery =  mapConactResponse.get(true);
                        mapInputs.put('contactRecordTypeId',contactRecordTypeId);
                        mapInputs.put('sContactId',sContactId);
                        objContact=RE_SharingByPassCtrl.getContactWrapper(sContactQuery,mapInputs);
                        acrMap=RE_SharingByPassCtrl.getACR(new List<Contact>{objContact},sAccountId);
                        objUserWrapper.Id = objContact.Id;
                        objUserWrapper.FirstName = objContact.FirstName;
                        objUserWrapper.LastName = objContact.LastName;
                        objUserWrapper.Phone = objContact.Phone;
                        objUserWrapper.Email = objContact.Email;
                        objUserWrapper.PermissionsLevel = objContact.PermissionsLevel__c;
                        objUserWrapper.TrainingLevel = objContact.TrainingLevel__c;
                        objUserWrapper.Status = (acrMap.containsKey(objContact.Id) && !acrMap.get(objContact.Id).IsActive)?RE_GlobalConstants.INACTIVE:objContact.Status__c;
                        objUserWrapper.isUserActive = (acrMap.containsKey(objContact.Id) && !acrMap.get(objContact.Id).IsActive)?false:true;
                        objUserWrapper.PrimaryLocation = objContact.PrimaryLocation__c;
                        objUserWrapper.isStatusChanged=false;
                    }
                    when SWITCH_FAILURE {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCtrl.class.getName(),'getWrapper',RE_GlobalConstants.FLS_ERROR + '' + mapConactResponse.get(false), true);
                    }
                }
            }catch(Exception e){
                errorMap.put('error',e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCtrl.class.getName(),'getWrapper',e.getMessage()+' '+e.getStackTraceString(), true);
             }
        }else{
            objUserWrapper.userdata = new User();
        }
        
        Boolean bIsAdmin =  false;
        List<PermissionSetAssignment> lstPermissionSet = GeneralUtility.geLoggedInUserPermissionSets();
            for(PermissionSetAssignment pmset : lstPermissionSet){
                if(pmset.PermissionSet.Name==RE_GlobalConstants.ADMIN_PERMISSIONSET_NAME){
                    bIsAdmin=true;
                }
            }
        bSuccess = true;
        objUserWrapper.bIsAdmin = bIsAdmin;
        objUserWrapper.lstLocations = lstLocation;
        mapResponse.put('userdata', JSON.serialize(objUserWrapper));
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /**************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   getPickListValues()
    * @description  This methods is used to get the picklist values from given sObject
    * @param        objectName          (String)   : sObject Name
    * @param        lstFields           (String)   : Multiple picklists separated by (,)
    * @return       RE_CreateLightningServerResponse 
    ******************************************************************************************/
    @AuraEnabled
    public static  RE_CreateLightningServerResponse getPickListValues(String strObjectName, String strLstFields){
        
        String objectName = String.escapeSingleQuotes(strObjectName);
        String lstFields = String.escapeSingleQuotes(strLstFields);
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
            try{
                Map<String, Map<String,String>> values = GeneralUtility.fetchFieldsPicklistValueAPIName(objectName, lstFields);
                bSuccess = true;
                mapResponse.put('picklistvalues', values);
            }catch(Exception e){
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCtrl.class.getName(),'getPickListValues', e.getMessage()+ ' '+e.getStackTraceString(), true);
            }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    
    /***************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   createContact()
    * @description  This methods is used to create a contact record
    * @param        RE_UserWrapper    (WrapperObject)   : User wrapper object contains user attributes
    * @param        bIsUpdate         (Boolean)         : To specify if it is an update or create
    * @return       RE_CreateLightningServerResponse 
    *****************************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse upsertContact(RE_UserWrapper objWrapper, Boolean bIsUpdate){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        Boolean skipcreationCode = false;
        User objUser = new User();
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        //RE Security Changes -- Payal
        List<String> lstEmail=new List<String>{objWrapper.Email};
        Map<String, Integer> mapContactEmailDuplicate =new Map<String,Integer>();
        String nonCitizenRecordTypeId=GeneralUtility.fetchRecordType(RE_GlobalConstants.strNonCitizenContactDevName, 'Contact').Id;
        String role=(objWrapper.PermissionsLevel==RE_GlobalConstants.ADMIN_ROLE)?RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN:RE_GlobalConstants.COMMUNITY_PARTNER_STAFF;
            try{
                Contact objContact = new Contact();
                String switchIdKey = (objWrapper.Id != null && objWrapper.Id != '') ? 'update' : 'create'; 
                //Code tp check duplicate contact - RE Security Changes
                //Force Reviewer Changes - Payal Dubela - 08/28
                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyIsCreate = (switchIdKey=='create')? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                switch on (switchCaseKeyIsCreate) {
                when SWITCH_SUCCESS {  
                    mapContactEmailDuplicate =GeneralUtility.checkDuplicateUser(lstEmail);
                     //Force Reviewer Changes - Payal Dubela - 08/28
                    RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyCheckDup = (mapContactEmailDuplicate!=null && mapContactEmailDuplicate.containsKey(objWrapper.Email) && mapContactEmailDuplicate.get(objWrapper.Email) >0 && !objWrapper.isClaimFlow)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                    switch on (switchCaseKeyCheckDup) {
                    when SWITCH_SUCCESS {  
                            bSuccess = false;
                            skipcreationCode=true;
                            errorMap.put('error',System.Label.contactmatchfounderror);
                    }
                    when SWITCH_FAILURE {
                        if (Schema.sObjectType.Contact.fields.PermissionsLevel__c.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible() && Schema.sObjectType.Contact.fields.Phone.isAccessible()
                        && Schema.sObjectType.Contact.fields.Id.isAccessible()){
                            //Query Contact with email to check for duplicate
                            Map<String,List<Contact>> conList = RE_SharingByPassCtrl.getDuplicateContacts(new List<String>{objWrapper.Email});
                            if(conList!=null && conList.containsKey(objWrapper.Email) && conList.get(objWrapper.Email).size()>1 && !objWrapper.isClaimFlow){
                                bSuccess = false;
                                skipcreationCode=true;
                                errorMap.put('error',System.Label.contactmatchfounderror);
                           }else if(conList!=null && conList.size()==1){
                               Map<String,Object> response = updateContactRole(objWrapper,role,(conList.get((objWrapper.Email).toLowerCase()))[0]);
                               bSuccess = Boolean.valueof(response.get('bSuccess'));
                               mapResponse.put('contactdata', response.get('contactdata'));
                               mapResponse.put('userdata', objUser); 
                               skipcreationCode=true;
                           }
                       }
                    }
                  }
                 }
              } 
            //Force Reviewer Changes - Payal Dubela - 08/28
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeySkipCode = (!skipcreationCode)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeySkipCode) {
            when SWITCH_SUCCESS {                                                                        
                switch on (switchIdKey) {
                    when 'create' {
                        objContact.Id = null;
                        //Added for RE-SSP merge
                        Account acc=GeneralUtility.createDummyAccount(objWrapper.FirstName,objWrapper.LastName,role); 
                        objContact.AccountId = acc.Id; 
                        objContact.ownerId = RE_SharingByPassCtrl.getAccountOwnerId(objContact.AccountId);
                        objContact.Status__c = RE_GlobalConstants.ACTIVE;
                    }
                    when 'update'{ 
                        objContact.Id = objWrapper.Id; 
                    }
                }
                objContact.FirstName = objWrapper.FirstName;
                objContact.LastName = objWrapper.LastName;
                objContact.Phone = objWrapper.Phone;
                objContact.Email = objWrapper.Email;
                objContact.PrimaryLocation__c = objWrapper.PrimaryLocation;
                objContact.RecordTypeId = nonCitizenRecordTypeId;
                objContact.PermissionsLevel__c = objWrapper.PermissionsLevel;
                objContact.TrainingLevel__c = (objWrapper.TrainingLevel != null) ? objWrapper.TrainingLevel : RE_GlobalConstants.CONTACT_TRAINING_LEVEL_NOT_TRAINED;
                objContact.IsClaim__c = objWrapper.bIsClaim;
                Map<Boolean, String> mapContactResponse = RE_DataAccessChecker.checkSafeFields(objContact);
                List<Contact> conList = new List<Contact>();
                RE_GlobalConstants.SWITCH_CONSTANTS switchContactUserKey = (mapContactResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
                switch on (switchContactUserKey) {
                    when SWITCH_SUCCESS {
                        if(objContact.Id == null){ // create contact and create user
                            RE_SharingByPassCtrl.insertSobject(objContact.getSobjectType(), objContact);
                            // get the permission set assignments from custom meta data based on Role - Admin/Staff
                            
                        }else{ // else update conact and user
                            //RE_DataAccessChecker.updateObject(Contact.getSObjectType(), objContact);
                            conList.add(objContact);
                            RE_SharingByPassCtrl.updateObjects(Contact.getSObjectType(), conList);
                        }
                        if(switchIdKey=='create'){
                            //Added for RE-SSP merge
                            if(objWrapper.AccountId != null){
                               GeneralUtility.createACR(RE_SharingByPassCtrl.getAccountId(objWrapper.AccountId),objContact.Id,role);
                            }else{
                                GeneralUtility.createACR(GeneralUtility.getLoggedInAccountId(),objContact.Id,role);
                            }
                        }

                        bSuccess = true;
                        mapResponse.put('contactdata', objContact);
                        mapResponse.put('userdata', objUser);
                    }
                    when SWITCH_FAILURE {
                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_UserCtrl.class.getName(), 'upsertContact', RE_GlobalConstants.FLS_ERROR + '' + mapContactResponse.get(false), true);
                    }
                }  
              } 
             } 
            }catch(Exception e){
                errorMap.put('error',e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCtrl.class.getName(), 'upsertContact', e.getMessage()+' '+e.getStackTraceString(), true);     
            }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /***************************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   updateUser()
    * @description  This methods is used to create a contact record
    * @param        RE_UserWrapper    (WrapperObject)   : User wrapper object contains user attributes
    * @return       RE_CreateLightningServerResponse 
    *****************************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateUser(Id userId, RE_UserWrapper objWrapper){
        GeneralUtility.isAuthenticatedUser();
        boolean boolRoleResponse = false; // Release_1.1 Role Management Variable - Srikanth
        Boolean bSuccess = false;
        Map<User, String> mapUserstobeUpdate =  new Map<User, String>();
        Boolean hasMultipleRole=false;
        List<User> lstUserstobeUpdate = new List<User>();
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try{
                    RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyIsUser = (userId != null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                    switch on (switchCaseKeyIsUser) {
                    when SWITCH_SUCCESS {  
                        User objUser = new User(Id = userId);
                        objUser.FirstName = objWrapper.FirstName;
                        objUser.ContactId = objWrapper.Id;
                        objUser.LastName = objWrapper.LastName;
                        objUser.Email = objWrapper.Email;
                        //Role Management implementation -- Srikanth Release_1.1 #START
                        
                        if(objWrapper.Status == RE_GlobalConstants.USER_STATUS_INACTIVE && objWrapper.isStatusChanged){
                            boolRoleResponse = validateRoleService(userId);
                            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyBoolRes = (boolRoleResponse == true) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
                            switch on (switchCaseKeyBoolRes) {
                            when SWITCH_SUCCESS {
                                User u = GeneralUtility.getUserRecord(userId);
                                String strPickListValue = u.ApplicableRoles__c;
                                List<String> lstPicklistValues = strPickListValue.split(';');
                                String selectedRole=u.ApplicableRoles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN)?RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN:(u.ApplicableRoles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_STAFF)?RE_GlobalConstants.COMMUNITY_PARTNER_STAFF:'');
                                //Update Account Records

                                String sQuery;
                                Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
                                Map<String, String> mapQueryParameters = new Map<String, String>();
                                Contact contactDetails=new Contact();
                                String strContactId = objWrapper.Id;
                                String sFieldsApiName = RE_DataBaseQueryFields.sIdStatusFields;
                                String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnContactIdValue;
                                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
                                mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                                mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strSobjectName, sFieldsApiName, mapQueryParameters);
                                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
                                switch on (switchCaseKey) {
                                    when SWITCH_SUCCESS {
                                        sQuery =  mapResponseData.get(true);
                                        contactDetails = RE_SharingByPassCtrl.getContactRecords(sQuery, strContactId); 
                                    }
                                    when SWITCH_FAILURE {
                                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserCtrl','updateUser','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                                    }
                                }

                                Account objAccount= new Account();
                                objAccount.Id=contactDetails.AccountId;
                                objAccount.Applicable_Roles__c='';
                                Map<Boolean, String> mapAccountResponse = RE_DataAccessChecker.checkSafeFields(objAccount);
                                RE_GlobalConstants.SWITCH_CONSTANTS switchAccountUserKey = (mapAccountResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
                                switch on (switchAccountUserKey) {
                                    when SWITCH_SUCCESS {
                                        RE_SharingByPassCtrl.updateSobject(Account.getSObjectType(), objAccount);
                                    }
                                    when SWITCH_FAILURE {
                                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_UserCtrl.class.getName(), 'updateUser', RE_GlobalConstants.FLS_ERROR + '' + mapAccountResponse.get(false), true);
                                    }
                                }    
                        
                                if(strPickListValue.contains(RE_GlobalConstants.RE_ASSISTER_ROLE)){
                                    lstPicklistValues.remove(lstPicklistValues.indexOf(selectedRole));
                                    updateApplicableRoleOnUser(userId,String.join(lstPicklistValues,';'));

                                }else{
                                List<UpdateSSOUser__e> publishEvents = new List<UpdateSSOUser__e>();
                                publishEvents.add(new UpdateSSOUser__e(UserId__c = objUser.Id ,Alias__c = objUser.LastName.substring(0,3)+String.valueOf(DateTime.now().getTime()).right(5),
                                                                    CommunityNickname__c = objUser.LastName.substring(0,3)+String.valueOf(DateTime.now().getTime()).right(5), FederationIdentifier__c = '',IsActive__c = false,UserName__c = u.Username ));
                                if(publishEvents.size()>0){
                                    EventBus.publish(publishEvents);
                                } 
                                }
                                AccountContactRelation acr=RE_SharingByPassCtrl.getACRRecord(objWrapper.Id, selectedRole,true);
                                Set<Id> setOfacrIds = new Set<Id>();
                                if(acr != null){
                                    acr.IsActive=false;
                                    RE_SharingByPassCtrl.updateObjects(AccountContactRelation.getSObjectType(),new List<AccountContactRelation>{acr});
                                }
                                bSuccess = true;
                                mapResponse.put('status','success');
                            }
                            when SWITCH_FAILURE {
                                String sQuery;
                                Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
                                Map<String, String> mapQueryParameters = new Map<String, String>();
                                Contact contactDetails=new Contact();
                                List<Contact> lstContactstobeUpdate = new List<Contact>();
                                String strContactId = objWrapper.Id;
                                String sFieldsApiName = RE_DataBaseQueryFields.sIdStatusFields;
                                String sWhereClause = RE_DataBaseQueryFields.sWhereClauseOnContactIdValue;
                                mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
                                mapQueryParameters.put(RE_GlobalConstants.sLimitKey, '1');
                                mapResponseData = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strSobjectName, sFieldsApiName, mapQueryParameters);
                                RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResponseData.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
                                switch on (switchCaseKey) {
                                    when SWITCH_SUCCESS {
                                        sQuery =  mapResponseData.get(true);
                                        //contactDetails = Database.query(sQuery);
                                        contactDetails = RE_SharingByPassCtrl.getContactRecords(sQuery, strContactId); 
                                    }
                                    when SWITCH_FAILURE {
                                        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserCtrl','updateUser','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                                    }
                                }
                                
                                contactDetails.Status__c = RE_GlobalConstants.USER_STATUS_ACTIVE;
                                lstContactstobeUpdate.add(contactDetails);
                                RE_SharingByPassCtrl.updateObjects(Contact.getSObjectType(), lstContactstobeUpdate);
                            
                                throw new applicationException(RE_GlobalConstants.RoleManagementError);
                            }
                         }  
                        }else if(objWrapper.Status == RE_GlobalConstants.USER_STATUS_INACTIVE){
                            lstUserstobeUpdate.add(objUser);
                            RE_SharingByPassCtrl.updateObjects(User.getSObjectType(), lstUserstobeUpdate);
                            bSuccess = true;
                            mapResponse.put('status','success');
                        }
                       
                        if(objWrapper.Status == RE_GlobalConstants.STATUS_ACTIVE && objWrapper.isStatusChanged){
                            String roleName=objWrapper.PermissionsLevel==RE_GlobalConstants.ADMIN_ROLE?RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN:RE_GlobalConstants.COMMUNITY_PARTNER_STAFF;
                            AccountContactRelation acr =RE_SharingByPassCtrl.getACRRecord(objWrapper.Id,roleName,false);
                            Set<Id> setOfacrIds = new Set<Id>();
                            if(acr != null && acr.IsActive==false){
                                acr.IsActive=true;
                                RE_SharingByPassCtrl.updateObjects(AccountContactRelation.getSObjectType(),new List<AccountContactRelation>{acr});
                            }
                            bSuccess = true;
                            mapResponse.put('status','success');
                        }else if(objWrapper.Status == RE_GlobalConstants.STATUS_ACTIVE){
                            lstUserstobeUpdate.add(objUser);
                            RE_SharingByPassCtrl.updateObjects(User.getSObjectType(), lstUserstobeUpdate);
                            bSuccess = true;
                            mapResponse.put('status','success');
                        }
                        //Role Management implementation #END
                    }
                  }
                }catch(Exception e){
                    errorMap.put('error',e.getMessage());
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_UserCtrl.class.getName(), 'updateUser', e.getMessage()+' '+e.getStackTraceString(), true);
                }
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapResponse);
    }
    /********************************************************************************************
* @author       Srikanth
* @date         03/26/2020
* @methodname   validateRoleService()
* @description  This method makes a service call and returns if user can be allowed to deactivate in Resource Engine
* @param        userId (Id)   : User id to Deactivate
* @return       boolean 
* Codes we get from external system:
    *1  Authorizations deleted successfully.
    *-110   Source System is required.
    *-120   Invalid Source System.
    *-130   Invalid User KOG ID.
    *-140   Invalid Application Name (�{Application Name}�).
    *-150   Invalid Role Name (�{Role Name}�).
    *-170   Role is not allowed to be deleted using this service method.
    *-191   AuthorizedBy User KOG ID is not valid.
    *-999   An Unknown error has occurred. Please try again later.

**********************************************************************************************/
    
    public static boolean validateRoleService(Id userId){
        
        Long startTime= DateTime.now().getTime();
        boolean isUserRoleValidated = false;
        Id loggedInUserId = UserInfo.getUserId();
        //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela ---Start
        user loggedinUser=new User();
        User userStatusUpdate= new User(); 
        String roleToRemove='';
        //Force Reviewer Changes - Payal Dubela - 08/28
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyLoggedInUser = (loggedInUserId!=null && userId!=null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKeyLoggedInUser) {
        when SWITCH_SUCCESS {
            for(User usr: [SELECT Id,FederationIdentifier,KOG_Role__c,ApplicableRoles__c 
                           FROM User 
                           WHERE (Id=:loggedInUserId 
                           OR Id=:userId) AND Id != null]){
             if(usr.Id==loggedInUserId){
                loggedinUser=usr; 
             }else if(usr.Id==userId){
                userStatusUpdate=usr;
             }
          }
        }
      }
      //Added this check as it was failing with muliple Role Scenario --- Payal Dubela
      roleToRemove=String.isNotBlank(userStatusUpdate.ApplicableRoles__c)?(userStatusUpdate.ApplicableRoles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN)?RE_GlobalConstants.COMMUNITY_PARTNER_ADMIN:(userStatusUpdate.ApplicableRoles__c.contains(RE_GlobalConstants.COMMUNITY_PARTNER_STAFF)?RE_GlobalConstants.COMMUNITY_PARTNER_STAFF:'')):'';
        //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela----End
        KOGWebservice__c objKog = KOGWebservice__c.getValues('KOG_Role_Management'); 
        List<schemasDatacontractOrg200407_Role.UserRole> lstdata = new List<schemasDatacontractOrg200407_Role.UserRole>();
        tempuriOrg_RoleMgmnt.BasicHttpsBinding_IRoleManagement roleRequest = new tempuriOrg_RoleMgmnt.BasicHttpsBinding_IRoleManagement();
        schemasDatacontractOrg200407_Role.ArrayOfMessageResponse roleResponse = new schemasDatacontractOrg200407_Role.ArrayOfMessageResponse();
        schemasDatacontractOrg200407_Role.ArrayOfUserRole rolesToRemove = new schemasDatacontractOrg200407_Role.ArrayOfUserRole();
        schemasDatacontractOrg200407_Role.UserRole attributevalues = new schemasDatacontractOrg200407_Role.UserRole();
        attributevalues.ApplicationName = objKog.ApplicationName__c; 
        attributevalues.RoleName = roleToRemove; // RE Security Changes - 09/02 - Payal Dubela
        lstdata.add(attributevalues);
        rolesToRemove.UserRole = lstdata; 
        roleRequest.clientCertName_x = objKog.Certificate__c; 
        roleRequest.endpoint_x = objKog.EndURL__c;
        String strRoleMagmntRequestData = '[Input Parameters : UserKOGID='+userStatusUpdate.FederationIdentifier+', Source System='+objKog.RE_ApplicationName__c+', role to Remove='+JSON.serialize(rolesToRemove)+',authorizedByUserKOGID='+loggedinUser.FederationIdentifier+']';
        try{
            roleResponse = roleRequest.RemoveRolesFromUser(userStatusUpdate.FederationIdentifier, objKog.RE_ApplicationName__c, rolesToRemove,loggedinUser.FederationIdentifier); 
        }
        catch(Exception ex){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(StackTrace__c = ex.getStackTraceString(), DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),ErroLog__c= 'Callout to Role Management Service is Failed', Source__c ='RE_UserCtrl',Message__c =  ex.getMessage() ,SourceFunction__c = 'validateRoleService', EndPoint__c = objKog.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,Integration_Payload__c = strRoleMagmntRequestData,InterfaceName__c = 'Role Management Service',ResponseData__c = JSON.serialize(roleResponse)));
            if(publishEvents.size()>0){ EventBus.publish(publishEvents);
            }  
     }
        
        if(roleResponse.MessageResponse != null){
        for(schemasDatacontractOrg200407_Role.MessageResponse msgResp : roleResponse.MessageResponse ){
            
            
            if(msgResp.MessageCode == 1){
                isUserRoleValidated = true;
            }
            else{
                List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
                publishEvents.add(new ErrorLog__e(StackTrace__c ='', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), ErroLog__c= 'Invalid Error Code From Role Management Service', Source__c ='RE_UserCtrl', Message__c = msgResp.MessageDescription ,SourceFunction__c = 'validateRoleService', EndPoint__c = objKog.EndURL__c,Timer__c = DateTime.now().getTime()-startTime,Integration_Payload__c = strRoleMagmntRequestData ,InterfaceName__c = 'Role Management',ResponseData__c = msgResp.MessageCode + msgResp.MessageDescription));
               if(publishEvents.size()>0){ EventBus.publish(publishEvents);
                }   
             }
        }
        }
        return isUserRoleValidated;
    }
    /********************************************************************************************
    * @author       Pankaj Mohanta
    * @date         08/05/2019
    * @methodname   updateUserStatusToActive()
    * @description  This methods is used to change the status of the inactive user to active before 
    *               making any changes to contact.
    * @param        sContactId           (String)   : conact record Id
    * @return       RE_CreateLightningServerResponse 
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse updateUserStatusToActive(String strContactId){
        
        String sContactId = String.escapeSingleQuotes(strContactId);
        GeneralUtility.isAuthenticatedUser();
        return RE_UserCreationHelper.updateUserStatusToActive(String.escapeSingleQuotes(sContactId));
    }

    /********************************************************************************************
    * @author       Payal Dubela
    * @date         08/06/2020
    * @methodname   updateContactRole()
    * @description  This methods is used check for duplicate contact with same email 
    * @param        Map<String, Object>           (String)   : conact record Id
    * @return       Boolean 
    **********************************************************************************************/
    public static Map<String, Object> updateContactRole(RE_UserWrapper objWrapper,String role,Contact objCon){
        Map<String, Object> mapResponse = new Map<String, Object>();
        String nonCitizenRecordTypeId=GeneralUtility.fetchRecordType(RE_GlobalConstants.strNonCitizenContactDevName, 'Contact').Id;
        Boolean bSuccess=false;
        Contact objContact = new Contact();
        Set<ID> contactIDs = new Set<ID>();
        Boolean isInactiveCP=false;
        AccountContactRelation acr = RE_SharingByPassCtrl.getInactiveACRRecord(objCon.Id,role);
        if(objCon.RecordTypeId==nonCitizenRecordTypeId && acr!=null){
            isInactiveCP=true;
        }
        //Update Dummy Account with Role
        Account objAccount= new Account();
        objAccount.Id=objCon.AccountId;
        if(String.isNotBlank(objCon.Account.Applicable_Roles__c) && !objCon.Account.Applicable_Roles__c.contains(role)){
            objAccount.Applicable_Roles__c=objCon.Account.Applicable_Roles__c+';'+role;
        }else{
            objAccount.Applicable_Roles__c=role;
        }
        Map<Boolean, String> mapAccountResponse = RE_DataAccessChecker.checkSafeFields(objAccount);
        RE_GlobalConstants.SWITCH_CONSTANTS switchAccountUserKey = (mapAccountResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchAccountUserKey) {
            when SWITCH_SUCCESS {
                RE_SharingByPassCtrl.updateSobject(Account.getSObjectType(), objAccount);
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_UserCtrl.class.getName(), 'upsertContact', RE_GlobalConstants.FLS_ERROR + '' + mapAccountResponse.get(false), true);
            }
        }    

        // ACR Creation
        if(objWrapper.AccountId != null){
            GeneralUtility.createACR(RE_SharingByPassCtrl.getAccountId(objWrapper.AccountId),objCon.Id,role);
        }else{
            GeneralUtility.createACR(GeneralUtility.getLoggedInAccountId(),objCon.Id,role);
        }

        //Change Recordtype of contact
        objContact.Id=objCon.Id;
        objContact.RecordTypeId=nonCitizenRecordTypeId;
        objContact.Phone = objWrapper.Phone;
        objContact.PrimaryLocation__c = objWrapper.PrimaryLocation;
        objContact.PermissionsLevel__c = objWrapper.PermissionsLevel;
        objContact.TrainingLevel__c = (objWrapper.TrainingLevel != null) ? objWrapper.TrainingLevel : RE_GlobalConstants.CONTACT_TRAINING_LEVEL_NOT_TRAINED;
        objContact.Status__c = objWrapper.Status;
        objContact.IsClaim__c = objWrapper.bIsClaim;

        Map<Boolean, String> mapContactResponse = RE_DataAccessChecker.checkSafeFields(objContact);
        RE_GlobalConstants.SWITCH_CONSTANTS switchContactUserKey = (mapContactResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchContactUserKey) {
            when SWITCH_SUCCESS {
                RE_SharingByPassCtrl.updateSobject(Contact.getSObjectType(), objContact);
                bSuccess=true;
                mapResponse.put('contactdata', objContact);
                
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_UserCtrl.class.getName(), 'upsertContact', RE_GlobalConstants.FLS_ERROR + '' + mapContactResponse.get(false), true);
            }
        } 
        contactIDs.add(objContact.Id);
        // Email send
        if(contactIDs.size() > 0){
            Database.executeBatch(new CPUserCreationBatch(contactIDs), 200);
        }
        if(isInactiveCP){
            String sContactId=objCon.Id;
            if(acr!=null){
               RE_SharingByPassCtrl.deleteACRRecord(new Set<Id>{acr.Id});
            }
        }

        mapResponse.put('bSuccess', bSuccess);
        return mapResponse;
    }

    //RE Security Changes -392204-Payal Dubela
    @future public static void updateApplicableRoleOnUser(String userId,String roleName){
        List<User> lstUserstobeUpdate= new  List<User>();
        User objUser = new User();
        objUser.Id=userId;
        objUser.ApplicableRoles__c=roleName;
        objUser.RE_Selected_Role__c = '';
        lstUserstobeUpdate.add(objUser);
        RE_SharingByPassCtrl.updateObjects(User.getSObjectType(), lstUserstobeUpdate);
    }

}