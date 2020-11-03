trigger ReferralTrigger on Referral__c (after insert, before insert) {
if(Test.isRunningTest() || ( TriggerSettings__c.getInstance('ReferralTrigger') != null && TriggerSettings__c.getInstance('ReferralTrigger').IsActive__c)) {
    new ReferralTriggerHandler().run();
    	if (Trigger.isBefore) {
            new ReferralTriggerHandler().checkBeforeReferralCreated(Trigger.new);
        }
        if (Trigger.isInsert && Trigger.isAfter) {
            new ReferralTriggerHandler().checkAfterReferralCreated(Trigger.new);
        }
    }
}