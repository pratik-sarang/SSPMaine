/*
* classname     :  SSP_AssetTrigger_Handler
* @description  :  This trigger calls the handler class methods for asset trigger.
* @author       :  Yathansh Sharma  
* @date         :  12/06/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
  Yathansh Sharma               12/06/2019                          Created.
**/
trigger SSP_Asset_Trigger on SSP_Asset__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    SSP_TriggerDispatcher.run(new SSP_AssetTrigger_Handler());
}