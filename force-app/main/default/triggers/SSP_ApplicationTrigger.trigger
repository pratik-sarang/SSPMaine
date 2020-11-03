/**
* triggername   : SSP_ApplicationTrigger
* @description  : Trigger executes on SSP_Application object
* @author       : Gunjyot
* @date         : 04/23/2020
**/
trigger SSP_ApplicationTrigger on SSP_Application__c (after insert, after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            SSP_MsgCenterApplnNotifyExpireHandler.expireNotifications(Trigger.old , Trigger.new , Trigger.newMap);
        }
    }
    //SSP_TriggerDispatcher.run(new SSP_MemberHandler());
}