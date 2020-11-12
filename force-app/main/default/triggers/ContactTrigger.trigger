trigger ContactTrigger on Contact (before insert, after insert, after update) {
    if(Test.isRunningTest() || ( TriggerSettings__c.getInstance('ContactTrigger') != null && TriggerSettings__c.getInstance('ContactTrigger').IsActive__c)) {
        new ContactTriggerHandler().run();
        // RE Security Changes -- Payal Dubela
       /* if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
            new ContactTriggerHandler().checkDuplicateEntry(); // added duplicate contact check as part of defect#341025
        }*/
        if (Trigger.isInsert && Trigger.isBefore) {
            new ContactTriggerHandler().createCitizenAccount();
        }
        if(Trigger.isAfter && Trigger.isInsert && !Test.isRunningTest()){
                new ContactTriggerHandler().communityPartnerCallOut();
        }
    }
}