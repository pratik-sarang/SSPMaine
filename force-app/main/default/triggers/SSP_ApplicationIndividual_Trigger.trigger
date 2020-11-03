/*
* classname     :  SSP_ApplicationIndividual_Trigger
* @description  :  This trigger calls the Application Individual Handler.
* @author       :  Karthik Gulla 
* @date         :  04/20/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
  Karthik Gulla                 12/06/2019                          Created.
**/
trigger SSP_ApplicationIndividual_Trigger on SSP_ApplicationIndividual__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SSP_TriggerDispatcher.run(new SSP_ApplicationIndividual_TriggerHandler());
}