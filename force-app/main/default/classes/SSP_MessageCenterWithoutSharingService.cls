/*
* classname         : SSP_MessageCenterWithoutSharingService
* @description      : This class provides service methods for Message Ceter in without sharing.
* @author           : Aniket Shinde
* @date             : 17/06/2019
* MODIFICATION LOG  :
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public without sharing class SSP_MessageCenterWithoutSharingService {
    /*
    * method        : expireDocCenterNotification
    * @description  : This method expire document center notifications
    * @author       : Aniket Shinde
    * @param        : Set<String> rfiIdentifierList
    * @return       : List<SSP_Notifications__c>
    * */    
    public static List<SSP_Notifications__c> expireDocCenterNotification(Set<String> rfiIdentifierList) {       
        list<SSP_Notifications__c> expireNotifications = new list<SSP_Notifications__c>();
        try{ 
           
            if(!rfiIdentifierList.isEmpty()){
                //for(SSP_Notifications__c notification : [select id, Status__c from SSP_Notifications__c where dmsDocumentId__c IN :rfiIdentifierList AND (notificationCode__c = :SSP_GlobalConstants.SF_TOD_004_DOCCENTER_CODE OR notificationCode__c = :SSP_GlobalConstants.SF_TOD_005_DOCCENTER_CODE)]){
                for(SSP_Notifications__c notification : [select id, Status__c from SSP_Notifications__c where dmsDocumentId__c IN :rfiIdentifierList]){
                    notification.Status__c = SSP_GlobalConstants.NOTIFICATION_EXPIRED;
                    expireNotifications.add(notification);
                }
            }
            if(!expireNotifications.isEmpty()){
                update expireNotifications;
            }
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterService', 'getMessageCenterData', ex.getMessage() , true);
        }                    
        return expireNotifications;
    }


    /*
    * method        : fetchNotifications
    * @description  : fetch notifications
    * @author       : Aniket Shinde
    * @param        : String source, String callingFlag, String toDoRecTypeId, String sysNotificationRecTypeId, String announcementRecTypeId, String noticeRecTypeId,Date today,List<String> recipientIdLst,List<String> programAccessForNotices, String userRole
    * @return       : map<string,List<SSP_Notifications__c>>
    * */  
    public static map<string,List<SSP_Notifications__c>> fetchNotifications(String source, String callingFlag, String toDoRecTypeId, String sysNotificationRecTypeId, String announcementRecTypeId, String noticeRecTypeId,Date today,List<String> recipientIdLst,List<String> programAccessForNotices, String userRole) {  
        map<string,List<SSP_Notifications__c>> fetchedDataMap = new map<string,List<SSP_Notifications__c>>();
        List<SSP_Notifications__c> lstSSPNotifications = new list<SSP_Notifications__c>();
        List<SSP_Notifications__c> lstToDo = new list<SSP_Notifications__c>();
        if(source=='citizenContext'){
            if(callingFlag =='MessageCenter'){
                // fix 377709 
                lstSSPNotifications =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                                from SSP_Notifications__c where 
                                                ( recordTypeId = :announcementRecTypeId AND 
                                                MessageCreateDate__c <= :today AND Expiry_Date__c >= :today )
                                                OR
                                                (
                                                    recordTypeId = :sysNotificationRecTypeId AND
                                                    Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                    recipientId__c IN :recipientIdLst AND
                                                    recipientType__c = :SSP_GlobalConstants.NOTIFICATION_CITIZEN
                                                )
                                                OR
                                                (
                                                    recordTypeId = :noticeRecTypeId AND
                                                    Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                    recipientId__c IN :recipientIdLst AND
                                                    recipientType__c = :SSP_GlobalConstants.NOTIFICATION_CITIZEN AND
                                                    (Program_Code__c IN :programAccessForNotices OR Program_Code__c = NULL )
                                                )
                                                order by MessageCreateDate__c desc];//for defect 393862
            }else if(callingFlag == 'Dashboard'){
                lstSSPNotifications =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                                    from SSP_Notifications__c where 
                                                    ( recordTypeId = :announcementRecTypeId AND 
                                                    MessageCreateDate__c <= :today AND Expiry_Date__c >= :today )
                                                    OR
                                                    (
                                                        recordTypeId = :sysNotificationRecTypeId AND
                                                        Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                        recipientId__c IN :recipientIdLst AND
                                                        recipientType__c = :SSP_GlobalConstants.NOTIFICATION_CITIZEN AND severity__c ='Critical'
                                                    )
                                                    order by createdDate asc];
            }
            lstToDo =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                from SSP_Notifications__c where 
                                recordTypeId = :toDoRecTypeId AND
                                Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                recipientId__c IN :recipientIdLst AND
                                recipientType__c = :SSP_GlobalConstants.NOTIFICATION_CITIZEN
                                order by dueDate__c asc];
        }
        else if(source=='nonCitizenContext'){
            // Roles who need RecipientId based notifications
            if(userRole == SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING 
            || userRole == SSP_GlobalConstants.ORGANISATION_AUTH_REP || userRole == SSP_GlobalConstants.ASSISTER_ROLE 
            || userRole == SSP_GlobalConstants.AGENCY_ADMIN_ROLE)
            {
                //fix 384093,380228
                String benefindCompatibleRoleStr = SSP_MessageCenterService.getOtherRoleString(userRole);
                if(callingFlag =='MessageCenter'){

                    //fix for 396847 - start 
                    /*
                        For Assister, Agency admin - non citizen dashboard
                        Notices would be queried based as per 
                    */
                    if(userRole == SSP_GlobalConstants.AGENCY_ADMIN_ROLE){
                        lstSSPNotifications =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                                    from SSP_Notifications__c where 
                                                    ( recordTypeId = :announcementRecTypeId AND 
                                                    MessageCreateDate__c <= :today AND Expiry_Date__c >= :today )
                                                    OR
                                                    (
                                                        recordTypeId = :sysNotificationRecTypeId AND
                                                        Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                        recipientId__c IN :recipientIdLst AND
                                                        //fix 384093
                                                        recipientType__c = :benefindCompatibleRoleStr
                                                    )
                                                    OR
                                                    (
                                                        recordTypeId = :noticeRecTypeId AND
                                                        Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                        AgencyId__c IN :recipientIdLst
                                                    )
                                                    order by MessageCreateDate__c desc];
                    }
                    else if(userRole == SSP_GlobalConstants.ASSISTER_ROLE){
                        lstSSPNotifications =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                                    from SSP_Notifications__c where 
                                                    ( recordTypeId = :announcementRecTypeId AND 
                                                    MessageCreateDate__c <= :today AND Expiry_Date__c >= :today )
                                                    OR
                                                    (
                                                        recordTypeId = :sysNotificationRecTypeId AND
                                                        Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                        recipientId__c IN :recipientIdLst AND
                                                        //fix 384093
                                                        recipientType__c = :benefindCompatibleRoleStr
                                                    )
                                                    OR
                                                    (
                                                        recordTypeId = :noticeRecTypeId AND
                                                        Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                        AgencyEmployeeId__c IN :recipientIdLst
                                                    )
                                                    order by MessageCreateDate__c desc];
                    }
                    else{
                        lstSSPNotifications =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                                    from SSP_Notifications__c where 
                                                    ( recordTypeId = :announcementRecTypeId AND 
                                                    MessageCreateDate__c <= :today AND Expiry_Date__c >= :today )
                                                    OR
                                                    (
                                                        (recordTypeId = :sysNotificationRecTypeId OR recordTypeId = :noticeRecTypeId) AND
                                                        Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                        recipientId__c IN :recipientIdLst AND
                                                        //fix 384093
                                                        recipientType__c = :benefindCompatibleRoleStr
                                                    )
                                                    order by MessageCreateDate__c desc];
                    }
                    //fix for 396847 - end
                }else if(callingFlag == 'Dashboard'){
                    lstSSPNotifications =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                                from SSP_Notifications__c where 
                                                ( recordTypeId = :announcementRecTypeId AND 
                                                MessageCreateDate__c <= :today AND Expiry_Date__c >= :today )
                                                OR
                                                (
                                                    (recordTypeId = :sysNotificationRecTypeId) AND
                                                    Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                                    recipientId__c IN :recipientIdLst AND
                                                    //fix 384093
                                                    recipientType__c = :benefindCompatibleRoleStr AND 
                                                    severity__c ='Critical'
                                                )
                                                order by createdDate asc];
                }
                lstToDo =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                from SSP_Notifications__c where 
                                recordTypeId = :toDoRecTypeId AND
                                Status__c = :SSP_GlobalConstants.NOTIFICATION_ACTIVE AND
                                recipientId__c IN :recipientIdLst AND
                                //fix 384093
                                recipientType__c = :benefindCompatibleRoleStr
                                order by dueDate__c asc];
            }
            // Roles who only need announcements
            else{
                lstSSPNotifications =  [select Benefind_Id__c , Case_Number__c , CreatedById , dmsDocumentId__c , dueDate__c , Expiry_Date__c , Is_Read__c , LastModifiedById , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , OwnerId , Program_Code__c , recipientId__c , recipientType__c , RecordTypeId , Reminder_Date__c , Severity__c , Name , MessageCreateDate__c , Status__c
                                            from SSP_Notifications__c where 
                                            recordTypeId = :announcementRecTypeId AND 
                                            MessageCreateDate__c <= :today AND Expiry_Date__c >= :today
                                            order by createdDate asc];
            }
        }
        list<SSP_Notifications__c> x = database.query('select Id, OwnerId, CreatedById, dueDate__c , Expiry_Date__c , Is_Read__c , Linked_Record_Id__c , messageSubject__c , messageSubjectES__c , Notification_Body__c , Notification_Body_Es__c , notificationCode__c , recipientType__c ,Severity__c , Name , MessageCreateDate__c , Program_Code__c, Status__c, RecordType.Name from SSP_Notifications__c where recipientId__c = \'890010114\' order by dueDate__c desc');
        fetchedDataMap.put('lstSSPNotifications',lstSSPNotifications);
        fetchedDataMap.put('lstToDo',lstToDo);
        return fetchedDataMap;
    }      

    public static List<SSP_Notifications__c> fetchNotifications(String recordId){
        return [Select Id,Name,Linked_Record_Id__c,recipientId__c,RequestAccessPermission__c,Notification_Body__c from SSP_Notifications__c where Id = :recordId]; //Only added RequestAccessPermission__c,Notification_Body__c field for Tracker Defect-56
    }
    
    public static List<SSP_Notifications__c> updateExpiredRecords(List<SSP_notifications__c> expireMsgRecords){
        update expireMsgRecords;
        return expireMsgRecords;
    }

    public static List<SSP_Notifications__c> updateReadStatusMsgNotices(List<SSP_notifications__c> updateReadStatusID){
        update updateReadStatusID;
        return updateReadStatusID;
    }
   
}