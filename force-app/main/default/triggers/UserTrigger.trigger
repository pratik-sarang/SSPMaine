trigger UserTrigger on User (after insert, after update, before insert, before update) {
    if(Test.isRunningTest() || ( TriggerSettings__c.getInstance('UserTrigger') != null && TriggerSettings__c.getInstance('UserTrigger').IsActive__c)) {
        /*if (Trigger.isInsert || Trigger.isUpdate) {
            //RE_UserTriggerHandler.addUsersToPublicGroup(Trigger.new);
        }
        if( Trigger.isUpdate && Trigger.isAfter){
            RE_UserTriggerHandler.deletePermsionSetAssignemnt();
        }*/
         if( Trigger.isInsert && Trigger.isAfter){
            RE_UserTriggerHandler.updateUserrolesToAccount(Trigger.new);
            RE_UserTriggerHandler.insertGroups(Trigger.new);
        }
    
    if(Trigger.isAfter && Trigger.isUpdate){
       RE_UserTriggerHandler.updateUserrolesToAccount(Trigger.new, Trigger.OldMap);
       RE_UserTriggerHandler.updateGroups(Trigger.new, Trigger.OldMap);
    }
   }

}