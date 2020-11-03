/*
* classname         : SSP_MessageCenterCtrl
* @description      : This class is controller for Document Ceter.
* @author           : Aniket Shinde
* @date             : 03/06/2019
* MODIFICATION LOG  :
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/ 
public with sharing  class SSP_MessageCenterCtrl {
    /**
     * @description : Wrapper class for Document Metadata
     */
    public class MessagesWrapper {
        @AuraEnabled public Boolean isAnnouncement {get;set;}
        @AuraEnabled public Boolean isToDo {get;set;}
        @AuraEnabled public Boolean isReadOnly {get;set;} //386073
        @AuraEnabled public Boolean isNotification {get;set;}
        @AuraEnabled public String subject {get;set;}
        @AuraEnabled public String details {get;set;}
        @AuraEnabled public String dueDate {get;set;}
        @AuraEnabled public String createdTimeStamp {get;set;}
        @AuraEnabled public Boolean readStatus {get;set;}
        @AuraEnabled public Boolean isExpiring {get;set;}
        @AuraEnabled public Boolean isCritical {get;set;}
        @AuraEnabled public String buttonName {get;set;}
        @AuraEnabled public String buttolAltText {get;set;}
        @AuraEnabled public String buttonAction {get;set;}
        @AuraEnabled public String mobileButtonName {get;set;}
        @AuraEnabled public String mobileButtonAltText {get;set;}
        @AuraEnabled public String mobileButtonAction {get;set;}
        @AuraEnabled public String trashAction {get;set;}
        @AuraEnabled public String sfdcId {get;set;}
        @AuraEnabled public String linkedId {get;set;}
        @AuraEnabled public String programCode {get;set;}
        @AuraEnabled public String caseNumber {get;set;}
        @AuraEnabled public String notificationId {get;set;}
        @AuraEnabled public Boolean showActionButton {get;set;} //#384763
    }

    /**
     * @description : Wrapper class for Document Metadata
     */
    public class NoticesWrapper {
        @AuraEnabled public Boolean readStatus {get;set;}
        @AuraEnabled public String subject {get;set;}
        @AuraEnabled public String dmsId {get;set;}
        @AuraEnabled public String createdTimeStamp {get;set;}
        @AuraEnabled public String sfdcId {get;set;}
        @AuraEnabled public String linkedId {get;set;}
        @AuraEnabled public String programCode {get;set;}
        @AuraEnabled public String caseNumber {get;set;}
        @AuraEnabled public Boolean dmsDocID {get;set;}//for fix 385373
    }

    /**
    * @author: Aniket Shinde
    * @method: initMessageCenter
    * @desc: Initiate data for message center
    */
    @AuraEnabled 
    public static SSP_LightningResponse initMessageCenter(string callingFlag) {
       SSP_LightningResponse objResponse = new SSP_LightningResponse();
       List<User> userLst;
       String primaryIndividualId;
       List<String> Citizen;
       String userRole;
       Set<String> availablePrograms;
       List<String> programAccessForNotices;
       map<string,SSP_Message_Center_Configuration__mdt> mdtMap;
       List<SSP_Notifications__c> lstSSPNotifications; // Announcements, Notifications, Notices
       List<SSP_Notifications__c> lstToDo;
       List<MessagesWrapper> wrapLstAnnouncement = new list<MessagesWrapper>();
       List<MessagesWrapper> wrapLstNotifications = new list<MessagesWrapper>();
       List<MessagesWrapper> wrapLstToDo = new list<MessagesWrapper>();
       List<NoticesWrapper> wrapLstNotices = new list<NoticesWrapper>(); //Notices ( Returend to LWC )
       List<MessagesWrapper> wrapLstMessagedMerged = new list<MessagesWrapper>(); //Announcements, Notifications, To Do ( Returend to LWC )
       Integer unreadMessagesCounter = 0;
       Integer unreadToDoCounter = 0;
       Integer unreadNotificationCounter = 0;
       Integer unreadNoticesCounter = 0;
       Integer totalNotices = 0;
       Integer dueTodos = 0;
       Integer totalToDos = 0;
       Integer unreadMessagesNotices = 0;
       try{
            userLst = SSP_Utility.getCurrentUserDetails();
            Map<String,String> mapUserDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());//Defect 38059 - Keshav
            userRole = mapUserDetails.get(SSP_GlobalConstants.USER_ROLE);
            availablePrograms = SSP_Utility.getAvailableProgramsByRole();
            String toDoRecTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('To Do').getRecordTypeId();
            String sysNotificationRecTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('System Notification').getRecordTypeId();
            String announcementRecTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('SSP Announcement').getRecordTypeId();
            String noticeRecTypeId = Schema.SObjectType.SSP_Notifications__c.getRecordTypeInfosByName().get('Notice').getRecordTypeId();
            mdtMap = SSP_MessageCenterCtrl.getMdtMap();
            // Time travel fix
            Date today=SSP_Utility.today();
            Date startOfWeek = today.toStartofWeek();
            Date endOfWeek = startOfWeek.addDays(7);
            String primaryIndId = ssp_utility.getIndividualId();
            map<string,string> demographicMaps = getDemographicForCitizen(userLst[0]);
            Map<String, Boolean> notifyCodeToAccessibilityMap = evaluateFieldPermissions(SSP_GlobalConstants.INDIVIDUAL_DASHBOARD_SCREENID); //#384763
            // Citizen OR Impersonised Citizen context
            if( userRole==SSP_GlobalConstants.CITIZEN_ROLE || 
                (primaryIndId!=null && primaryIndId!='' && mapUserDetails.get('profileName')==SSP_GlobalConstantS.RE_CITIZEN_PROFILE)|| //Defect 38059 - Keshav
                mapUserDetails.get('impersonatedIndividualId') != null){//Defect 38059 - Keshav
                
                programAccessForNotices = new List<String>();
                /*For citizen - notices with all programs*/
                if(userRole==SSP_GlobalConstants.CITIZEN_ROLE){
                    programAccessForNotices.addAll(SSP_GlobalConstants.ALL_PROGRAMS);
                }
                /*Auth rep access maps based fetch accessible programs (per case-prgram map basis filtering happens further)*/
                else if(userRole==SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING || userRole==SSP_GlobalConstants.ORGANISATION_AUTH_REP){
                    map<String,Set<String>> authRepAccessForNotices;
                    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                    String authRepAccessForNoticesString = sessionPart.get('authRepAccessForNotices') != null ? String.valueOf(sessionPart.get('authRepAccessForNotices')) : 
                                                    String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices'))) ?
                                                            String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices')) : '';
                    if(authRepAccessForNoticesString != null && authRepAccessForNoticesString != '' && wrapLstNotices != null){
                        authRepAccessForNotices = (map<String,Set<String>>)JSON.deserialize(authRepAccessForNoticesString, map<String,Set<String>>.class);
                        for(String caseNo : authRepAccessForNotices.keySet()){
                            programAccessForNotices.addAll(authRepAccessForNotices.get(caseNo));
                        }
                    }
                }
                /* for all other roles - role programs access for notices*/
                else{
                    programAccessForNotices.addAll(SSP_Utility.getAvailableProgramsByRole());
                }
                
                List<String> lstIndId = (ssp_utility.getCurrentUserAllIndividualIds()).split(';');

                //fetch notifications in without sharing context
                map<string,List<SSP_Notifications__c>> fetchedDataMap = SSP_MessageCenterWithoutSharingService.fetchNotifications('citizenContext',callingFlag,toDoRecTypeId,sysNotificationRecTypeId,announcementRecTypeId,noticeRecTypeId,today,lstIndId,programAccessForNotices,userRole);
                lstSSPNotifications = fetchedDataMap.get('lstSSPNotifications');
                lstToDo = fetchedDataMap.get('lstToDo');
                totalToDos = lstToDo.size();

                for(SSP_Notifications__c notificationRec: lstSSPNotifications){
                    if(notificationRec.recordTypeId==announcementRecTypeId){
                        MessagesWrapper msgWrap = getMessageWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c),null); //386073 add only null
                        msgWrap.isAnnouncement=true;
                        // Announcement doesn't have read/unread, keep default read
                        msgWrap.readStatus = true;
                        wrapLstAnnouncement.add(msgWrap);
                    }
                    else if(notificationRec.recordTypeId==sysNotificationRecTypeId){
                        if((callingFlag == 'MessageCenter')|| (callingFlag=='Dashboard' && notificationRec.Severity__c =='Critical')){
                            if(notificationRec.Expiry_Date__c==null || notificationRec.Expiry_Date__c>=today){//for fix 385598
                        MessagesWrapper msgWrap= getMessageWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c), null); //386073 add only null
                        msgWrap.isNotification=true;
                        unreadNotificationCounter++;
                        wrapLstNotifications.add(msgWrap);
                            }
                            }
                        
                        if(!notificationRec.Is_Read__c){
                            unreadMessagesCounter++;
                           
                        }
                    }
                    else if(notificationRec.recordTypeId==noticeRecTypeId && callingFlag =='MessageCenter'){
                        if(notificationRec.Expiry_Date__c==null || notificationRec.Expiry_Date__c>=today){//for fix 385598
                        wrapLstNotices.add(getNoticeWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c)));
                        totalNotices++;
                        if(!notificationRec.Is_Read__c){
                            unreadNoticesCounter++;
                        }
                        }
                    }
                }
                for(SSP_Notifications__c notificationRec: lstToDo){

                    MessagesWrapper msgWrap = new MessagesWrapper();
                         if(((callingFlag == 'MessageCenter') || (callingFlag == 'DashBoard'&& notificationRec.Severity__c == 'Critical')) && (notificationRec.dueDate__c == null || notificationRec.dueDate__c >= today)){////notificationRec.dueDate__c  as per defect 382089
                        if(notificationRec.Expiry_Date__c==null || notificationRec.Expiry_Date__c>=today){//for fix 385598
                        msgWrap = getMessageWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c),userRole); //386073 add only UserRole
                        msgWrap.isToDo = true;
                        }
                        wrapLstToDo.add(msgWrap);
                        if(!notificationRec.Is_Read__c){
                            unreadMessagesCounter++;
                            unreadToDoCounter++;
                        }

                        if(notificationRec.dueDate__c>=startOfWeek && notificationRec.dueDate__c<=endOfWeek){
                            dueTodos++;
                        }
                    }
                }
                /*For auth reps ( impersonisation ) - access based filtering */
                if(userRole==SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING || userRole==SSP_GlobalConstants.ORGANISATION_AUTH_REP){
                    wrapLstNotices = filterNoticeAuthRepImpersonateAccess(wrapLstNotices);
                }
                unreadMessagesNotices = unreadMessagesCounter + unreadNoticesCounter;
            }
            //NON CITIZEN
            else{
                String contactId = (SSP_Utility.getUserDetails(UserInfo.getUserId())).get('contactId');
                list<String> listNonCitizenIdentifier = new list<String>();
                // 384092 - fix start
                // DCOrganizationId Id based logic
                if(userRole == SSP_GlobalConstants.ORGANISATION_AUTH_REP || userRole == SSP_GlobalConstants.AGENCY_ADMIN_ROLE){
                    String userRoleTemp = userRole;
                    // Fix 389948
                    if(userRole == SSP_GlobalConstants.AGENCY_ADMIN_ROLE){
                        userRoleTemp = SSP_GlobalConstants.ASSISTER_ROLE;
                    }
                    for(AccountContactRelation objACR : [select id, Account.DCDataId__c from AccountContactRelation where 
                                                Account.DCDataId__c != null AND  Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION 
                                                AND ContactId = :contactId AND Roles includes (: userRoleTemp )]) //Defect - 387442 / // Fix 389948
                    {
                        if(objACR.Account.DCDataId__c != null)
                        {
                            Integer intVal = (objACR.Account.DCDataId__c).intValue();
                            listNonCitizenIdentifier.add(String.valueOf(intVal));
                        }
                    }
                }
                // DCUserId Id based logic
                else{
                    for(AccountContactRelation objACR : [select id, DCContactId__c from AccountContactRelation where 
                                                DCContactId__c != null AND  Account.Recordtype.Name = :SSP_GlobalConstants.ORGANIZATION 
                                                AND ContactId = :contactId AND Roles = :userRole])
                    {
                        if(objACR.DCContactId__c != null)
                        {
                            Integer intVal = (objACR.DCContactId__c).intValue();
                            listNonCitizenIdentifier.add(String.valueOf(intVal));
                        }
                    }
                }
                // 384092 - fix end
                //fetch notifications in without sharing context
                map<string,List<SSP_Notifications__c>> fetchedDataMap = SSP_MessageCenterWithoutSharingService.fetchNotifications('nonCitizenContext',callingFlag,toDoRecTypeId,sysNotificationRecTypeId,announcementRecTypeId,noticeRecTypeId,today,listNonCitizenIdentifier,programAccessForNotices,userRole);
                lstSSPNotifications = fetchedDataMap.get('lstSSPNotifications');
                lstToDo = fetchedDataMap.get('lstToDo');
                
                for(SSP_Notifications__c notificationRec: lstSSPNotifications){
                    if(notificationRec.recordTypeId==announcementRecTypeId){
                        MessagesWrapper msgWrap = getMessageWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c),null);//386073 add only null
                        msgWrap.isAnnouncement=true;
                        wrapLstAnnouncement.add(msgWrap);
                        
                    }
                    else if(notificationRec.recordTypeId==sysNotificationRecTypeId){
                        if((callingFlag == 'MessageCenter')|| (callingFlag=='Dashboard' && notificationRec.Severity__c =='Critical')){
                            if(notificationRec.Expiry_Date__c==null || notificationRec.Expiry_Date__c>=today){//for fix 385598
                            MessagesWrapper msgWrap= getMessageWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c),null);//386073 add only null
                            msgWrap.isNotification=true;
                            wrapLstNotifications.add(msgWrap);
                            }
                        } 
                        if(!notificationRec.Is_Read__c){
                            unreadMessagesCounter++;
                            unreadNotificationCounter++;
                        }
                    }
                    else if(notificationRec.recordTypeId==noticeRecTypeId && callingFlag =='MessageCenter'){
                        if(notificationRec.Expiry_Date__c==null || notificationRec.Expiry_Date__c>=today){//for fix 385598
                        wrapLstNotices.add(getNoticeWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c)));
                        }
                        if(!notificationRec.Is_Read__c){
                            unreadNoticesCounter++;
                        }
                    }
                }
                for(SSP_Notifications__c notificationRec: lstToDo){
                    MessagesWrapper msgWrap = new MessagesWrapper();
                        if(((callingFlag == 'MessageCenter') || (callingFlag == 'DashBoard'&& notificationRec.Severity__c == 'Critical')) && (notificationRec.dueDate__c == null || notificationRec.dueDate__c >= today)){//notificationRec.dueDate__c  as per defect 382089
                           if(notificationRec.Expiry_Date__c==null || notificationRec.Expiry_Date__c>=today){//for fix 385598
                            msgWrap = getMessageWrapInstance(notificationRec,demographicMaps,mdtMap.get(notificationRec.notificationCode__c),userRole);//386073 add only User role
                        msgWrap.isToDo = true;
                           }
                        wrapLstToDo.add(msgWrap);
                        if(!notificationRec.Is_Read__c){
                            unreadMessagesCounter++;
                            unreadToDoCounter++;
                        }
                        if(notificationRec.dueDate__c>=startOfWeek && notificationRec.dueDate__c<=endOfWeek){
                            dueTodos++;
                        }
                    }
                }
                
                unreadMessagesNotices = unreadMessagesCounter + unreadNoticesCounter;
            }
            
            wrapLstMessagedMerged.addAll(wrapLstToDo);
            wrapLstMessagedMerged.addAll(wrapLstAnnouncement);
            wrapLstMessagedMerged.addAll(wrapLstNotifications);
            wrapLstMessagedMerged = filterNotifications(wrapLstMessagedMerged, notifyCodeToAccessibilityMap); //#384763
            objResponse.put('messages', wrapLstMessagedMerged);
           if(callingFlag == 'MessageCenter'){
               objResponse.put('notices', wrapLstNotices);
               objResponse.put('countOfUnreadNotices', unreadNoticesCounter);
           }
            objResponse.put('countOfUnreadMessages', unreadMessagesCounter);
            objResponse.put('countOfUnreadToDos', unreadToDoCounter);
            objResponse.put('countOfUnreadNotifications', unreadNotificationCounter);
            objResponse.put('todosDue',dueTodos);
            objResponse.put('totaltodos',totalToDos);
           objResponse.put('totalNotices',totalNotices);
           objResponse.put('unreadMessagesNotices' ,unreadMessagesNotices);
            objResponse.bIsSuccess = true;

        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterCtrl', 'initMessageCenter', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }

    /*
    *   Get SSP message wrapper for Announcements, ToDo, Notofications
    */
    private static MessagesWrapper getMessageWrapInstance(SSP_Notifications__c notificationRec, Map<String,String> demographicMap, SSP_Message_Center_Configuration__mdt mdtRec,String userRole){
         	
        MessagesWrapper msgWrap = new MessagesWrapper();
        /*386073 start*/
        // Fix 386073v1 - start
        List<String> readOnlyRoleList = (System.Label.SSP_ReadOnlyRoles).split(';');
        if(readOnlyRoleList != null && !readOnlyRoleList.isEmpty())
        {
            Set<String> readOnlyRoleSet = new Set<String> (readOnlyRoleList);
            msgWrap.isReadOnly= (readOnlyRoleSet != null && userRole != null) ? readOnlyRoleSet.contains(userRole) : false;
        }
        else{
            msgWrap.isReadOnly = false;
        }
        // Fix 386073v1 - end
        /*End*/
        msgWrap.notificationId = notificationRec.notificationCode__c;
        if(demographicMap.get('locale')== SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH){
            msgWrap.subject=notificationRec.messageSubjectES__c;
            msgWrap.details=notificationRec.Notification_Body_Es__c;
        }
        else{
            msgWrap.subject=notificationRec.messageSubject__c;
            msgWrap.details=notificationRec.Notification_Body__c;
        }
        if(notificationRec.dueDate__c != null)
            //390055 - Fix
            msgWrap.dueDate=notificationRec.dueDate__c.month() + '/' + Integer.valueOf(String.valueOfGMT(notificationRec.dueDate__c).split('-')[2].split(' ')[0]) + '/' + notificationRec.dueDate__c.year();

        //Fix 381802
        if(notificationRec.MessageCreateDate__c != null)
            msgWrap.createdTimeStamp=notificationRec.MessageCreateDate__c.month() + '/' + notificationRec.MessageCreateDate__c.day() + '/' + notificationRec.MessageCreateDate__c.year();
        
        //Time Travel Fix
        Date currentDate=SSP_Utility.today();
        //modified for Bug 384023
        Date twoDaysBack = Date.newInstance((currentDate.addDays(-2)).year(), (currentDate.addDays(-2)).month() , (currentDate.addDays(-2)).day());
        if(notificationRec.Expiry_Date__c>=twoDaysBack){
            msgWrap.isExpiring=true;
        }
        else{
            msgWrap.isExpiring=false;
        }
        if(notificationRec.Severity__c!=null && notificationRec.Severity__c=='Critical')
            msgWrap.isCritical=true;
        else
            msgWrap.isCritical=false;
        if(mdtRec!=null)
        {
                msgWrap.buttonName = mdtRec.Button_Name__c;  
            msgWrap.buttolAltText = mdtRec.Button_Alt_Text__c;
            msgWrap.buttonAction = mdtRec.button_Action__c;
            msgWrap.mobileButtonName = mdtRec.Mobile_Button_Name__c;
            msgWrap.mobileButtonAltText = mdtRec.Mobile_Button_Alt_Text__c;
            msgWrap.mobileButtonAction = mdtRec.Mobile_Button_Action__c;
            msgWrap.trashAction = mdtRec.Trash_Action__c;
        }
        if(notificationRec.Is_Read__c)
            msgWrap.readStatus = true;
        else
            msgWrap.readStatus = false;
        msgWrap.sfdcId=notificationRec.Id;
        msgWrap.linkedId=notificationRec.Linked_Record_Id__c;
        msgWrap.programCode = notificationRec.Program_Code__c;
        msgWrap.caseNumber = notificationRec.Case_Number__c;
        return msgWrap;
    }

    /*
    *   Get SSP notice wrapper for Notices
    */
    private static NoticesWrapper getNoticeWrapInstance(SSP_Notifications__c notificationRec, Map<String,String> demographicMap, SSP_Message_Center_Configuration__mdt mdtRec){
        NoticesWrapper noticeWrap = new NoticesWrapper();
        if(demographicMap.get('locale')== SSP_GlobalConstants.LANGUAGE_CODE_US_SPANISH){
            noticeWrap.subject=notificationRec.messageSubjectES__c;
        }
        else{
            noticeWrap.subject=notificationRec.messageSubject__c;
        }
        noticeWrap.dmsId=notificationRec.dmsDocumentId__c;
        
        //for fix 385373--start
        if(notificationRec.dmsDocumentId__c!=null){
            noticeWrap.dmsDocID = true;
        }else{
            noticeWrap.dmsDocID = false;
        }
        //for fix 385373--end

        //Fix 381802
        if(notificationRec.MessageCreateDate__c!=null)
            noticeWrap.createdTimeStamp=notificationRec.MessageCreateDate__c.month() + '/' + notificationRec.MessageCreateDate__c.day() + '/' + notificationRec.MessageCreateDate__c.year();

        if(notificationRec.Is_Read__c)
            noticeWrap.readStatus = true;
        else
            noticeWrap.readStatus = false;
        noticeWrap.sfdcId=notificationRec.Id;
        noticeWrap.linkedId=notificationRec.Linked_Record_Id__c;
        noticeWrap.programCode = notificationRec.Program_Code__c;
        noticeWrap.caseNumber = notificationRec.Case_Number__c;
        return noticeWrap;
    }

    /*
    *   Get metadata map
    */
    public static map<string,SSP_Message_Center_Configuration__mdt> getMdtMap(){
        map<string,SSP_Message_Center_Configuration__mdt> mdtMap = new  map<string,SSP_Message_Center_Configuration__mdt>();
        for(SSP_Message_Center_Configuration__mdt mdtRec : [select Id, Code__c, Body__c, Body_Spanish__c, Title__c, 
        Title_Spanish__c, Due_Date_criterion__c, Expiry_Date_Criterion__c,
        Send_Reminder_Criteria__c, Communication_Body__c, Communication_Body_Spanish__c, Severity__c, Trash_Action__c,
        toLabel(Button_Name__c), toLabel(Button_Alt_Text__c), button_Action__c, Mobile_Button_Action__c, toLabel(Mobile_Button_Alt_Text__c), toLabel(Mobile_Button_Name__c)
        from SSP_Message_Center_Configuration__mdt]){
            mdtMap.put(mdtRec.Code__c,mdtRec);
        }
        return mdtMap;
    }

    /*
    *   Get demographic map
    */
    private static map<string,string> getDemographicForCitizen(User usr){
        map<String,String> mapLocalCopy = new map<string,string>();
        mapLocalCopy.put('name',usr.contact.Salutation+' '+usr.contact.name);
        mapLocalCopy.put('locale',usr.LanguageLocaleKey);
        return mapLocalCopy;
    }

    /**
    * @author: Aniket Shinde
    * @method: updateReadStatus
    * @desc: updateReadStatus
    */
    @AuraEnabled 
    public static SSP_LightningResponse updateReadStatus(/*List<Id> notificationId*/string notificationId) {
        Integer i;
      List<String> notificationIds = (List<String>)JSON.deserialize(notificationId, List<String>.class);
        List<SSP_Notifications__c>updateReadStatusID = new List<SSP_Notifications__c>();
        for(i=0;i<notificationIds.size();i++){
            SSP_Notifications__c notificationRec = new SSP_Notifications__c(Id=notificationIds[i],Is_Read__c=true);
            updateReadStatusID.add(notificationRec);
        }
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try{
            updateReadStatusID = SSP_MessageCenterWithoutSharingService.updateReadStatusMsgNotices(updateReadStatusID);
            objResponse.bIsSuccess = true;
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterCtrl', 'initMessageCenter', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }

    /**
    * @author: Aniket Shinde
    * @method: filterNoticeAuthRepImpersonateAccess
    * @desc: filter notices based upon access for auth reps when impersonating
    */
    Static List<NoticesWrapper> filterNoticeAuthRepImpersonateAccess(List<NoticesWrapper> wrapLstNotices){
        List<NoticesWrapper> filteredNotices = new List<NoticesWrapper>();
        map<String,Set<String>> authRepAccessForNotices;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        String authRepAccessForNoticesString = sessionPart.get('authRepAccessForNotices') != null ? String.valueOf(sessionPart.get('authRepAccessForNotices')) : 
                                        String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices'))) ?
                                                String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'authRepAccessForNotices')) : '';
        if(authRepAccessForNoticesString != null && authRepAccessForNoticesString != '' && wrapLstNotices != null){
            authRepAccessForNotices = (map<String,Set<String>>)JSON.deserialize(authRepAccessForNoticesString, map<String,Set<String>>.class);
            set<string> accessibleCases = authRepAccessForNotices.keySet();
            for(NoticesWrapper noticeWrap : wrapLstNotices){
                // fix 377709 
                if(accessibleCases.contains(noticeWrap.caseNumber) && 
                    (
                        noticeWrap.programCode == null || (authRepAccessForNotices.get(noticeWrap.caseNumber)).contains(noticeWrap.programCode)
                    ) 
                )
                {
                        filteredNotices.add(noticeWrap);
                }
            }
        }
        return filteredNotices;
    }

    //#384763
    private static List<MessagesWrapper>  filterNotifications(List<MessagesWrapper> wrapLstMessagedMerged, Map<String, Boolean> notifyCodeToAccessibilityMap){
        List<MessagesWrapper> updatedWrapLstMessagedMerged = new List<MessagesWrapper>();        
        if(wrapLstMessagedMerged != null && !wrapLstMessagedMerged.isEmpty()){
            for(MessagesWrapper wrap : wrapLstMessagedMerged){
                if(notifyCodeToAccessibilityMap != null && String.isNotBlank(wrap.notificationId) && notifyCodeToAccessibilityMap.containsKey(wrap.notificationId) && !notifyCodeToAccessibilityMap.get(wrap.notificationId)){
                    wrap.showActionButton = false;
                }
                else{
                    wrap.showActionButton = true;
                }
                updatedWrapLstMessagedMerged.add(wrap);
            }
        }        
        return updatedWrapLstMessagedMerged;

    }

    //#384763  - Method to construct field permission details
    private static Map<String,Boolean> evaluateFieldPermissions(String screenId){
        Map<String, String> notifyCodeToFieldIdMap = new Map<String, String>{
            SSP_GlobalConstants.continueNotificationCode => SSP_GlobalConstants.continueFieldId
        };

        Map<String, Boolean> permissionMap = new Map<String, Boolean>();

        SSP_Utility.SecurityMatrixWrapper  securityWrapper = SSP_Utility.getScreenAccessDetails(screenId, null);
        if(securityWrapper != null && securityWrapper.fieldPermissions != null && !securityWrapper.fieldPermissions.isEmpty()){
            for(String notificationCode : notifyCodeToFieldIdMap.keySet()){
                String fieldId = notifyCodeToFieldIdMap.get(notificationCode);
                Boolean isAccessible = true;
                if(securityWrapper.fieldPermissions.containsKey(fieldId)){
                    String permssion = securityWrapper.fieldPermissions.get(fieldId);
                    isAccessible = String.isNotBlank(permssion) && permssion.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE) ? false : isAccessible;
                    
                }
                permissionMap.put(notificationCode, isAccessible);
            }
        }
        
        return permissionMap;
    }
}