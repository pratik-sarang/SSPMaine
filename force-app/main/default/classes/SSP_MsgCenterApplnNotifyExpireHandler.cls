public class SSP_MsgCenterApplnNotifyExpireHandler {
    public static boolean expireNotifications(List<SSP_Application__c>Triggerold , List<SSP_Application__c>Triggernew , Map<Id,SSP_Application__c>TriggernewMap){
       List<SSP_Notifications__c> updateStatus = new List<SSP_Notifications__c>();
		List<String> recordsToExpire = new List<string>();
        boolean status;
        try{
			for(SSP_Application__c appliRec : Triggerold){
				SSP_Application__c newAppliRec = TriggernewMap.get(appliRec.Id);
				if((newAppliRec.Status__c == 'P' || newAppliRec.Status__c == 'Inactive') && (newAppliRec.Status__c != appliRec.Status__c)){
					recordsToExpire.add(newAppliRec.Id);
				}
			}
			if(!recordsToExpire.isEmpty())
			{
				for(SSP_Notifications__c changeStatus : [select id , Linked_Record_Id__c , Status__c from SSP_Notifications__c where Linked_Record_Id__c IN :recordsToExpire]){
									changeStatus.Status__c = 'Expired';
									updateStatus.add(changeStatus);
				}
			}
			if(!updateStatus.isEmpty())
			{
				Database.update(updateStatus,false);
			}
        	status = true;    
		}catch(Exception ex){
			List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_MessageCenterApplicationReminder', 'execute', ex.getMessage() , true);
    		status = false;
        }
        return status;
    }
}