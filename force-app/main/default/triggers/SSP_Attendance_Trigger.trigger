/*
* classname     :  SSP_Attendance_Trigger
* @description  :  This trigger calls the Attendance Handler.
* @author       :  Karthik Gulla 
* @date         :  06/22/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
  Karthik Gulla                 22/06/2020                          Created.
**/
trigger SSP_Attendance_Trigger on SSP_Attendance__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SSP_TriggerDispatcher.run(new SSP_Attendance_TriggerHandler());
}