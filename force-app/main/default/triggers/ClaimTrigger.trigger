trigger ClaimTrigger on ClaimMySiteRequest__c (before update) {
    if(Test.isRunningTest() || ( TriggerSettings__c.getInstance('ClaimsTrigger') != null && TriggerSettings__c.getInstance('ClaimsTrigger').IsActive__c)){
        if (Trigger.isBefore && Trigger.isUpdate) {
          ClaimTriggerHandler.checkDuplicateEntry(Trigger.new,Trigger.oldMap);
    }
  }
}