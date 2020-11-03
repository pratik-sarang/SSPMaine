/**
 * Class Name    : SSP_MessageCenterNotificationExpire
 * Author        : Payal Dubela
 * Created Date  : 16-June-2020
 * Description   : This batch class expires the notification after 10 days of creation
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------*/
global class SSP_MessageCenterNotificationExpire implements Database.Batchable<sObject>, Schedulable{
    
    private Date dateOveride;

    //386265 fix - start
    global SSP_MessageCenterNotificationExpire(){

    }
    global SSP_MessageCenterNotificationExpire(Date dateParam){
        this.dateOveride = dateParam;
    }
    //386265 fix - end
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String notificationStatus=SSP_GlobalConstants.NOTIFICATION_ACTIVE;
  
        //386265 fix
        Date todayDate;
        if(dateOveride!=null){
            todayDate = dateOveride;
        }
        else{
            todayDate=SSP_Utility.today();
        }
        string query = 'Select Id,Name,Status__c,Expiry_Date__c,notificationCode__c FROM SSP_Notifications__c'+ 
                        ' WHERE Status__c=:notificationStatus AND Expiry_Date__c=:todayDate'+
                        ' AND (notificationCode__c LIKE \'%'+SSP_GlobalConstants.SF_NOT_002_CODE+'%\''+
                        ' OR notificationCode__c LIKE \'%'+SSP_GlobalConstants.SF_NOT_003_CODE+'%\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<SSP_Notifications__c> scopeNotification){
        List<SSP_Notifications__c> listToUpdate = new List<SSP_Notifications__c>();
        SSP_Notifications__c notObj;
        try{
            for(SSP_Notifications__c notification: scopeNotification){
                if(notification.notificationCode__c.equals(SSP_GlobalConstants.SF_NOT_002_CODE)
                   || notification.notificationCode__c.equals(SSP_GlobalConstants.SF_NOT_003_CODE)){   
                        notObj= new SSP_Notifications__c();
                        notObj.Id=notification.Id;
                        notObj.Status__c=SSP_GlobalConstants.NOTIFICATION_EXPIRED;
                        listToUpdate.add(notObj);
                   }
            }
        if(!listToUpdate.isEmpty()){
            Database.update(listToUpdate,false);
        }
       }catch(Exception ex) {
        List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterNotificationExpire', 'execute', ex.getMessage()+' '+ex.getStackTraceString(), true);
      } 
 }
    global void finish(Database.BatchableContext bc){
        
    }    
    
    global void execute(SchedulableContext sc) {
        SSP_MessageCenterNotificationExpire batchObj = new SSP_MessageCenterNotificationExpire();
        database.executebatch(batchObj);
    }

}