trigger LocationTrigger on Location__c (before insert, before update) {
    if(Test.isRunningTest() || 
       ( TriggerSettings__c.getInstance('LocationTrigger') != null 
        && TriggerSettings__c.getInstance('LocationTrigger').IsActive__c))
    {
        
        new LocationTriggerHandler().run();
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isBefore) {
           new LocationTriggerHandler().UpdateLocations();
      }
        
    }
}