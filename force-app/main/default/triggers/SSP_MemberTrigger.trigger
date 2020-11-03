/**
* triggername   : SSP_MemberTrigger
* @description  : Trigger executes on SSP_Member object
* @author       : Ashwin Kasture
* @date         : 03/05/2020
**/
trigger SSP_MemberTrigger on SSP_Member__c (after insert, after update) {
    SSP_TriggerDispatcher.run(new SSP_MemberHandler());
}