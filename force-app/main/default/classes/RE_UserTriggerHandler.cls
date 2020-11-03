/**
* Class Name    : RE_UserTriggerHandler
* Owner         : DELOITTE
* Created Date  : 12/09/2019
* Description   : Handler class for User Trigger
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  12/09/2019  Pankaj          Initial Version
*                              Security/Object access checks have not been applied on this class as it is querying on standard object
*
*  17/12/2019  Utkarsh         Cyclomatic complexity reduced in if else statements - Blocks line 52 to 77 & 77 to 100
**/
public with sharing class RE_UserTriggerHandler extends TriggerHandler {
    public RE_UserTriggerHandler() {
        this.setMaxLoopCount(5);//recursive handling
    } 
    /*
    public static void addUsersToPublicGroup(List<User> lstUsers){
        try{
            if(Schema.sObjectType.Profile.fields.Id.isAccessible() && Schema.sObjectType.Profile.fields.Name.isAccessible()){
            // map to store profile id and respective profile
            Map<Id,Profile> profileMap = new Map<ID, Profile>([SELECT Id,Name FROM Profile LIMIT 5000]);
            // get public groups mapping from custom setting
            List<PublicGroupAssignments__c> lstPublicGroups = PublicGroupAssignments__c.getall().values();
            // map for public group assignments
            Map<String, String> mapProfilePublicGroup = new Map<String, String>();
            // map for queue assignments
            Map<String, String> mapProfileQueueAssignment = new Map<String, String>();
            // map for public trigger setting
            Map<String, Boolean> mapProfileExecuteTriggerSetting = new Map<String, Boolean>();
            Set<String> setGroupName = new Set<String>();
            Map<String, String> mapUserToGroup = new Map<String, String>();
            for(PublicGroupAssignments__c obj :lstPublicGroups){
                mapProfilePublicGroup.put(obj.ProfileName__c, obj.PublicGroupName__c);
                mapProfileExecuteTriggerSetting.put(obj.ProfileName__c, obj.Executeforallchanges__c);
                if(obj.QueueName__c != null){
                    mapProfileQueueAssignment.put(obj.ProfileName__c, obj.QueueName__c);
                }
                    else{
                        setGroupName.add(obj.PublicGroupName__c);
            }
                }
            // get all the public groups from the org
                   RE_GlobalConstants.SWITCH_CONSTANTS switchContactUserKey = (Schema.sObjectType.Group.fields.Id.isAccessible() && Schema.sObjectType.Group.fields.Name.isAccessible() 
                   && Schema.sObjectType.Group.fields.DeveloperName.isAccessible() && Schema.sObjectType.Group.fields.Type.isAccessible()) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                      switch on (switchContactUserKey){
                           when SWITCH_SUCCESS {
                   List<Group> lstPGList = [SELECT Id, Name,DeveloperName FROM Group WHERE Type = 'Regular' OR Type='Queue'];
                   
                   Map<String, String> mapPublicGroupNameId = new Map<String, String>();
                   for(Group g:lstPGList){
                       mapPublicGroupNameId.put(g.DeveloperName, g.Id);
                   }
                   List<GroupMember>listGroupMember =new List<GroupMember>();  
                   // loop the users 
                   for (User user : lstUsers) {
                       if(Trigger.isUpdate){
                           User oldUser =  (User)Trigger.oldMap.get(user.Id);
                           GroupMember gm= new GroupMember(); 
                           String sProfileName = profileMap.get(user.ProfileId).Name;
                           Boolean listGroupMemberValidate;
                           if(sProfileName != null && mapProfilePublicGroup.get(sProfileName) != null 
                              && mapPublicGroupNameId.get(mapProfilePublicGroup.get(sProfileName))!=null
                              && user.IsActive == true && (oldUser.profileId != user.profileId && mapProfileExecuteTriggerSetting.get(sProfileName)== true)){
                                  gm.GroupId=  mapPublicGroupNameId.get(mapProfilePublicGroup.get(sProfileName));
                                  gm.UserOrGroupId = user.id;
                                  listGroupMember.add(gm);
                                  listGroupMemberValidate = true;
                              }
                                  // if the current user is state user or UW staff user then add them into Queue
                                  if(listGroupMemberValidate==true && sProfileName != null && (sProfileName == RE_GlobalConstants.RE_UW_STAFF_USER ||sProfileName == RE_GlobalConstants.RE_STATE_USER)){
                                      GroupMember grp= new GroupMember(); 
                                      String sQueueName = mapProfileQueueAssignment.get(sProfileName);
                                      if(sQueueName != null){
                                          grp.GroupId = mapPublicGroupNameId.get(sQueueName);
                                          grp.UserOrGroupId = user.id;
                                          listGroupMember.add(grp);
                                          
                                      }
                                  }
                              
                       }else if(Trigger.isInsert){
                           GroupMember gm= new GroupMember(); 
                           String sProfileName = profileMap.get(user.ProfileId).Name;
                           Boolean listGroupMemberValidate;
                           if(sProfileName != null && mapProfilePublicGroup.get(sProfileName) != null 
                              && mapPublicGroupNameId.get(mapProfilePublicGroup.get(sProfileName))!=null
                              && user.IsActive == true ){
                                  gm.GroupId=  mapPublicGroupNameId.get(mapProfilePublicGroup.get(sProfileName));
                                  gm.UserOrGroupId = user.id;
                                  //RE_Release 1.3 – Bug 372485 - Payal Dubela
                                  if(sProfileName==RE_GlobalConstants.strAgencyProfileName){
                                     mapUserToGroup.put(user.id, mapPublicGroupNameId.get(mapProfilePublicGroup.get(sProfileName)));
                                  }else{
                                     listGroupMember.add(gm);   
                                  }
                                  listGroupMemberValidate = true;
                              }
                                  // if the current user is state user or UW staff user then add them into Queue
                                  if(listGroupMemberValidate==true && sProfileName != null && (sProfileName == RE_GlobalConstants.RE_UW_STAFF_USER ||sProfileName == RE_GlobalConstants.RE_STATE_USER)){
                                      GroupMember grp= new GroupMember(); 
                                      String sQueueName = mapProfileQueueAssignment.get(sProfileName);
                                      if(sQueueName != null){
                                          grp.GroupId = mapPublicGroupNameId.get(sQueueName);
                                          grp.UserOrGroupId = user.id;
                                          listGroupMember.add(grp); 
                                      }
                                  }
                              
                       }
                       
                   }// end of for loop
                       if(listGroupMember!=null && listGroupMember.size() > 0 && Schema.sObjectType.GroupMember.isCreateable()){
                                  if( Trigger.isUpdate){
                                        deleteGroupMember(listGroupMember, setGroupName);
                                    }
                           insert listGroupMember;
                       }
                       //RE_Release 1.3 – Bug 372485 - Payal Dubela
                       if(mapUserToGroup!=null && mapUserToGroup.keyset().size()>0){
                                   insertGroupMember(mapUserToGroup);
                       }
                   }
            }
            }
        }catch(Exception e){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), Message__c = e.getMessage(),StackTrace__c = e.getStackTraceString()+lstUsers, Source__c ='RE_UserTriggerHandler',SourceFunction__c = 'addUsersToPublicGroup'));
            if(publishEvents.size()>0) EventBus.publish(publishEvents);
        }
    } 
    public static void deleteGroupMember(List<GroupMember> listGroupMember, Set<String> setGroupName){
        Map<Id, User> mapUsers = (Map<Id, User>)Trigger.newMap;
        Map<Id, User> mapOldUsers = (Map<Id, User>)Trigger.OldMap;
        Set<String> setUsrId = new Set<String>();
        List<GroupMember>listDeleteGroupMember =new List<GroupMember>();
        for(GroupMember grpMbr : listGroupMember){
            setUsrId.add(grpMbr.UserOrGroupId);
        }
        List<GroupMember> lstGroupMembers = [SELECT Group.DeveloperName, UserOrGroupId FROM GroupMember where Group.DeveloperName IN: setGroupName AND UserOrGroupId IN: setUsrId];
        if(!lstGroupMembers.isEmpty()){
            for(GroupMember mebr : lstGroupMembers){
                User usr = mapUsers.get(mebr.UserOrGroupId);
                User usrOldV = mapOldUsers.get(mebr.UserOrGroupId);
                if(usr != null && usrOldV != null && usrOldV.ProfileId != usr.ProfileId){
                    listDeleteGroupMember.add(mebr);
                }
            }
            if(!listDeleteGroupMember.isEmpty()){
                delete listDeleteGroupMember;
            }
        }
    }
    
    public static void deletePermsionSetAssignemnt(){
        Map<Id, User> mapUsers = (Map<Id, User>)Trigger.newMap;
        Map<Id, User> mapOldUsers = (Map<Id, User>)Trigger.OldMap;
        List<PermissionSetAssignment>  lstDeleteAssignments = new List<PermissionSetAssignment>();
        Set<String> setPermissionSetName = new Set<String>();
        Map<String, String> MapPermissionSetName = new Map<String, String>();
        try{
            List<KOG_Role_Permission_Set_Mapping__c> lstRolesNdPermsnSt = KOG_Role_Permission_Set_Mapping__c.getall().values();
            for(KOG_Role_Permission_Set_Mapping__c roleNPrms : lstRolesNdPermsnSt){
                setPermissionSetName.add(roleNPrms.Permission_Set__c);
                MapPermissionSetName.put(roleNPrms.KOG_Role__c, roleNPrms.Permission_Set__c);
            }
            Map<String, String> mapPermisnSetIdNdName = new Map<String, String>();
            for(PermissionSet prm :[SELECT Id, Name FROM PermissionSet WHERE Name IN: setPermissionSetName ]){
                mapPermisnSetIdNdName.put(prm.Name, prm.Id);
            }
            
            Map<String, String> mapRoleName = new Map<String, String>();
            List<PermissionSetAssignment> lstInserUserAssignments = new List<PermissionSetAssignment>();
            List<PermissionSetAssignment> lstPrmsnStAssnmnt = [SELECT AssigneeId, PermissionSet.Name, PermissionSetId FROM PermissionSetAssignment WHERE  AssigneeId IN: mapUsers.keySet() AND PermissionSet.Name IN: setPermissionSetName];
            
            if(!lstPrmsnStAssnmnt.isEmpty()){
                for(PermissionSetAssignment asnmnts : lstPrmsnStAssnmnt){
                    User usr = mapUsers.get(asnmnts.AssigneeId);
                    User usrOld = mapOldUsers.get(asnmnts.AssigneeId);
                    if(usr != null && usr.KOG_Role__c != null && usrOld.KOG_Role__c != usr.KOG_Role__c && usrOld.KOG_Role__c!= null && MapPermissionSetName.get(usrOld.KOG_Role__c).equalsIgnoreCase(asnmnts.PermissionSet.Name)){
                        
                        lstDeleteAssignments.add(asnmnts);
                        mapRoleName.put(usr.Id, usr.KOG_Role__c);
                    }
                }
                if(!lstDeleteAssignments.isEmpty()){
                    delete lstDeleteAssignments;
                }
            }
             for(User usr : mapUsers.values()){
                 User usrOld = mapOldUsers.get(usr.Id);
                 if(usrOld.KOG_Role__c != usr.KOG_Role__c && usr.KOG_Role__c != null && MapPermissionSetName.containsKey(usr.KOG_Role__c) ){
                    PermissionSetAssignment prseAss = new PermissionSetAssignment();
                    prseAss.AssigneeId = usr.Id;
                    prseAss.PermissionSetId = mapPermisnSetIdNdName.get(MapPermissionSetName.get(usr.KOG_Role__c));
                    lstInserUserAssignments.add(prseAss);
                 
                 }
             }
              
                if(!lstInserUserAssignments.isEmpty()){
                     insert lstInserUserAssignments;
                }
                
        }catch(Exception e){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), Message__c = e.getMessage(),StackTrace__c = e.getStackTraceString(), Source__c ='RE_UserTriggerHandler',SourceFunction__c = 'deletePermsionSetAssignemnt'));
            if(publishEvents.size()>0) EventBus.publish(publishEvents);
        }
    }
    //RE_Release 1.3 – Bug 372485 - Payal Dubela
    @future
    public static void insertGroupMember(Map<String,String> groupMemberToInsert){
        GroupMember gm; 
        List<GroupMember>listGroupMember =new List<GroupMember>();  
        try{
        for(String userId:groupMemberToInsert.keyset()){
            gm= new GroupMember(); 
            gm.GroupId= groupMemberToInsert.get(userId) ;
            gm.UserOrGroupId = userId;
            listGroupMember.add(gm);
        }
        if(listGroupMember!=null && listGroupMember.size() > 0 && Schema.sObjectType.GroupMember.isCreateable()){
            insert listGroupMember;
        }
      }catch(Exception e){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), Message__c = e.getMessage(),StackTrace__c = e.getStackTraceString()+groupMemberToInsert, Source__c ='RE_UserTriggerHandler',SourceFunction__c = 'insertGroupMember'));
            if(publishEvents.size()>0) EventBus.publish(publishEvents);
      }
    } 
    */

     /********************************************************************************************
    * @author       Suresh
    * @date         07/28/2020
    * @methodname   updateUserrolesToAccount()
    * @description  update user roles on account
    * @return       void
    **********************************************************************************************/
    public static void updateUserrolesToAccount(List<User> lstUsers, Map<Id, User> mapOldUsrs){
        
        List<User> lstUsrs = new List<User>();
        for(User usr : lstUsers){
            User oldUsrVrsn = mapOldUsrs.get(usr.Id);
            if(oldUsrVrsn.ApplicableRoles__c != usr.ApplicableRoles__c){
                lstUsrs.add(usr);
            }
        }
        if(!lstUsrs.isEmpty() && !System.isFuture() && !System.isBatch()){
            updateUserrolesToAccount(lstUsrs);
        }
       
    }
    
    public static void updateUserrolesToAccount(List<User> lstUsers){
        
        map<Id,String> mapRolesToAccount = new map<Id,String>();
        List<Account> lstAccountToUpdateRoles = new List<Account>();
        
        Map<Id, User> mapUsrs = new Map<Id, User>(lstUsers);
        // SCA fix : Kojashree
        List<User> lstQrdUsers = new List<User>();
        if(Schema.sObjectType.User.fields.Id.isAccessible() && Schema.sObjectType.User.fields.ContactId.isAccessible() && Schema.sObjectType.User.fields.ApplicableRoles__c.isAccessible() ){
           lstQrdUsers =  [SELECT Id, ContactId, Contact.AccountId, ApplicableRoles__c FROM User WHERE Id IN: mapUsrs.keySet()];
        }
     String strRERoles;
        System.debug('lstQrdUsers-'+lstQrdUsers);
        for(User usr : lstQrdUsers){
            strRERoles ='';
            if(usr.ApplicableRoles__c != null && usr.ContactId != null && usr.Contact.AccountId != null ){
                strRERoles = getRERoles(usr.ApplicableRoles__c);
                if( String.isNotBlank(strRERoles) ){
                    mapRolesToAccount.put(usr.Contact.AccountId,strRERoles);
                }
                else{
                    mapRolesToAccount.put(usr.Contact.AccountId,'');
                }
                
            }
            else if(usr.ApplicableRoles__c == null && usr.ContactId != null && usr.Contact.AccountId != null){
                mapRolesToAccount.put(usr.Contact.AccountId,'');
            }
        }
        if(mapRolesToAccount!=null && !System.isFuture() && !System.isBatch()){
            updateApplicableRole(mapRolesToAccount);
        }
   
    }
     /********************************************************************************************
    * @author       Suresh
    * @date         07/28/2020
    * @methodname   getRERoles()
    * @description  get appicable roles
    * @return       String
    **********************************************************************************************/
    public static String getRERoles(String strRoles){
        List<String> lstApplcbleRoles = new List<String>();
        lstApplcbleRoles = strRoles.Split(';');
        Map<String, String> mapRECSTMSetngRoles = new Map<String, String>();
        for(PublicGroupAssignments__c role : PublicGroupAssignments__c.getall().values()){
            mapRECSTMSetngRoles.put(role.ProfileName__c, role.ProfileName__c);
        }
        String strRERoles ='';
        for(String strRole : lstApplcbleRoles){
            if(mapRECSTMSetngRoles.containsKey(strRole)){
                strRERoles = String.isNotBlank(strRERoles)?strRERoles+';'+strRole:strRole;
            }
        }
        return strRERoles;
    }
    
     /********************************************************************************************
    * @author       Suresh
    * @date         07/28/2020
    * @methodname   updateGroups()
    * @description  update user roles on account
    * @return       void
    **********************************************************************************************/
    public static void updateGroups(List<User> lstUsers, Map<Id, User> mapOldUsrs){
        
        Map<String, String> mapUsrRoles = new Map<String, String>();
        Map<String, String> mapUsrRolesToDelete = new Map<String, String>();
        Set<String> strRoles = new Set<String>();
        List<User> lstUsrs = new List<User>();
        List<String> newRoles;
        List<String> removeRoles;
        for(User usr : lstUsers){
            User oldUsrVrsn = mapOldUsrs.get(usr.Id);
            if(oldUsrVrsn.ApplicableRoles__c != usr.ApplicableRoles__c){
                mapUsrRoles.put(usr.Id, usr.ApplicableRoles__c);
                List<String> lstOldPicklistValues = oldUsrVrsn.ApplicableRoles__c!=null?oldUsrVrsn.ApplicableRoles__c.split(';'): new List<String>();
                if(String.isNotBlank(usr.ApplicableRoles__c)){
                    for(String appRole:usr.ApplicableRoles__c.split(';')){
                        if(lstOldPicklistValues.contains(appRole)){
                            lstOldPicklistValues.remove(lstOldPicklistValues.indexOf(appRole));
                        }
                    }
                }
                mapUsrRolesToDelete.put(usr.Id,String.join(lstOldPicklistValues,';'));
                newRoles = new List<String>();
                if(String.isNotBlank(usr.ApplicableRoles__c)){
                    newRoles = usr.ApplicableRoles__c.split(';');
                }
                strRoles.addAll(newRoles);
                removeRoles = new List<String>();
                if(String.isNotBlank(oldUsrVrsn.ApplicableRoles__c)){
                    removeRoles = oldUsrVrsn.ApplicableRoles__c.split(';');
                }
                strRoles.addAll(removeRoles);
            }
        }
        
        //Delete public groups
        if(!mapUsrRolesToDelete.isEmpty())
        deletGroupsAssignement(mapUsrRolesToDelete, getRolesNDGroups(strRoles));
        
        //Assign public groups
        if(!mapUsrRoles.isEmpty() && !System.isFuture() && !System.isBatch())
        insertGroupMember(mapUsrRoles, getRolesNDGroups(strRoles));
        
    }
    
     /********************************************************************************************
    * @author       Suresh
    * @date         07/28/2020
    * @methodname   insertGroups()
    * @description  insert public goup on user insertion
    * @return       void
    **********************************************************************************************/
    public static void insertGroups(List<User> lstUsers){
        Map<String, String> mapUsrRoles = new Map<String, String>();
        Set<String> strRoles = new Set<String>();
        List<User> lstUsrs = new List<User>();
        List<String> newRoles;
        for(User usr : lstUsers){
            if(usr.ApplicableRoles__c != null){
                mapUsrRoles.put(usr.Id, usr.ApplicableRoles__c);
                newRoles = new List<String>(usr.ApplicableRoles__c.split(';'));
                strRoles.addAll(newRoles);
            }
        }
        //Assign public groups
        if(!mapUsrRoles.isEmpty() && !System.isFuture() && !System.isBatch())
        insertGroupMember(mapUsrRoles, getRolesNDGroups(strRoles));
    }
    
     /********************************************************************************************
    * @author       Suresh
    * @date         07/28/2020
    * @methodname   insertGroupMember()
    * @description  Assign public groups
    * @return       void
    **********************************************************************************************/
    @future
    public static void insertGroupMember(Map<String,String> groupMemberToInserts, Map<String, String> mapRolesNdGrp){
        
        Map<String,List<String>> groupMemberToInsert = new Map<String,List<String>>();
        for(String userId:groupMemberToInserts.keyset()){
            groupMemberToInsert.put(userId, (groupMemberToInserts.get(userId)).split(';'));
        }
        GroupMember gm; 
        GroupMember queueMbr; 
        List<GroupMember>listGroupMember =new List<GroupMember>();  
        try{
        for(String userId:groupMemberToInsert.keyset()){
            for(String rol : groupMemberToInsert.get(userId)){
                
                if(String.isNotBlank(rol) && mapRolesNdGrp.containsKey(rol)){
                    gm= new GroupMember(); 
                    gm.GroupId = mapRolesNdGrp.get(rol);
                    gm.UserOrGroupId = userId;
                    listGroupMember.add(gm);
                }
                if(rol.equalsIgnoreCase('RE United Way Staff') || rol.equalsIgnoreCase('State User')){
                    queueMbr = new GroupMember();
                    queueMbr.GroupId = mapRolesNdGrp.get('ClaimSiteQueue');
                    queueMbr.UserOrGroupId = userId;
                    listGroupMember.add(queueMbr);
                }
            }
        }
        if(!listGroupMember.isEmpty() ){//&& Schema.sObjectType.GroupMember.isCreateable()
            RE_SharingByPassCtrl.insertObjects(GroupMember.getSObjectType(), listGroupMember);
        }
      }catch(Exception e){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), Message__c = e.getMessage(),StackTrace__c = e.getStackTraceString()+groupMemberToInsert, Source__c ='RE_UserTriggerHandler',SourceFunction__c = 'insertGroupMember'));
            if(publishEvents.size()>0) EventBus.publish(publishEvents);
      }
    }
    
    /********************************************************************************************
    * @author       Suresh
    * @date         07/28/2020
    * @methodname   deletGroupsAssignement()
    * @description  delete public groups
    * @return       void
    **********************************************************************************************/
    public static void deletGroupsAssignement(Map<String,String> groupMemberToDlt, Map<String,String> mapRolesNdGrp){
        Map<String,List<String>> groupMemberToDelete = new Map<String,List<String>>();
        for(String userId:groupMemberToDlt.keyset()){
            if(String.isNotBlank(groupMemberToDlt.get(userId))){
                groupMemberToDelete.put(userId, groupMemberToDlt.get(userId).split(';'));
            }
        }
        Set<Id> usrIds = new Set<Id>();
        Set<Id> groupdId = new Set<Id>();
         for(String userId:groupMemberToDelete.keyset()){
            for(String rol : groupMemberToDelete.get(userId)){
                if(mapRolesNdGrp.containsKey(rol)){
                    usrIds.add(userId);
                    groupdId.add(mapRolesNdGrp.get(rol));
                }
                if(rol.equalsIgnoreCase('RE United Way Staff') || rol.equalsIgnoreCase('State User')){
                    groupdId.add(mapRolesNdGrp.get('ClaimSiteQueue'));
                }
            }
         }
        
         List<GroupMember> lstDeleteGrpMembers = [SELECT GroupId,UserOrGroupId FROM GroupMember WHERE GroupId IN:groupdId AND UserOrGroupId IN:usrIds];
        
        try{
        if(!lstDeleteGrpMembers.isEmpty() && Schema.sObjectType.GroupMember.isDeletable())
            RE_SharingByPassCtrl.deleteObjects(GroupMember.getSObjectType(), lstDeleteGrpMembers);
        }catch(Exception e){
            List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
            publishEvents.add(new ErrorLog__e(DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error), Message__c = e.getMessage(),StackTrace__c = e.getStackTraceString()+lstDeleteGrpMembers, Source__c ='RE_UserTriggerHandler',SourceFunction__c = 'deletGroupsAssignement'));
            if(publishEvents.size()>0) EventBus.publish(publishEvents);
      }
        
    }
    
     /********************************************************************************************
    * @author       Suresh
    * @date         07/28/2020
    * @methodname   getRolesNDGroups()
    * @description  get public groups & Roles
    * @return       Map
    **********************************************************************************************/
    public static Map<String, String> getRolesNDGroups(Set<String> strRoles){
    Map<String, PublicGroupAssignments__c> mapGroups = new Map<String, PublicGroupAssignments__c>();
        for(PublicGroupAssignments__c pblcGrp : [SELECT Id, ProfileName__c, PublicGroupName__c, QueueName__c FROM PublicGroupAssignments__c WHERE ProfileName__c IN: strRoles AND ProfileName__c != null]){
            if(String.isNotBlank(pblcGrp.PublicGroupName__c)){
            mapGroups.put(pblcGrp.PublicGroupName__c, pblcGrp);
            }
            if(String.isNotBlank(pblcGrp.QueueName__c)){
                mapGroups.put(pblcGrp.QueueName__c, pblcGrp);
            }
        }
        Map<String, String> mapRolesNdGrp = new Map<String, String>();
        if(!mapGroups.isEmpty()){
            for(Group grp :[SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN:mapGroups.keySet() AND (Type = 'Regular' OR Type='Queue')]){
                SYstem.debug(mapGroups.containsKey(grp.DeveloperName)+'::grp:::'+grp.DeveloperName);
                if(mapGroups.containsKey(grp.DeveloperName)){
                    mapRolesNdGrp.put(mapGroups.get(grp.DeveloperName).ProfileName__c, grp.Id);
                    if(String.isNotBlank(mapGroups.get(grp.DeveloperName).QueueName__c) && grp.DeveloperName.equalsIgnoreCase(mapGroups.get(grp.DeveloperName).QueueName__c)){
                        mapRolesNdGrp.put(mapGroups.get(grp.DeveloperName).QueueName__c, grp.Id);
                    }
                    
                }
                
            }
        }
        return mapRolesNdGrp;
    }
    /********************************************************************************************
    * @author       Payal
    * @date         08/31/2020
    * @methodname   updateApplicableRole()
    * @description  update applicable role on Account
    * @return       Map
    **********************************************************************************************/
    @future
    public static void updateApplicableRole(Map<Id,String> mapRolesToAccount){
        List<Account> lstAccountToUpdateRoles = new List<Account>();
        if(Schema.sObjectType.Account.fields.Applicable_Roles__c.isAccessible()){
            for(Account acc: [Select Id,Applicable_Roles__c FROM Account WHERE Id IN:mapRolesToAccount.keySet()]){
                acc.Applicable_Roles__c = mapRolesToAccount.get(acc.Id);
                lstAccountToUpdateRoles.add(acc);
            }
        }
        try{
            if(!lstAccountToUpdateRoles.isEmpty() && Schema.sObjectType.Account.isUpdateable()){
                RE_SharingByPassCtrl.updateObjects(Account.getSObjectType(), lstAccountToUpdateRoles);
            }
        }catch(Exception ex){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_UserTriggerHandler', 'updateUserrolesToAccount', ex.getMessage()+' '+ex.getStackTraceString(), true);
        }

    }

}