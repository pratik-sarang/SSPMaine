/*
* classname     :  SSP_ITriggerHandler
* @description  :  This is the interface that dictates which methods every trigger handler must implement,
					even if these methods have no code in them. By implementing the methods in this class,
					the TriggerDispatcher can be confident that the trigger handler has a method for each of the events.
* @author       :  Yathansh Sharma   
* @date         :  12/06/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                             	DESCRIPTION
* ---------------------------------------------------------------------------------------------
  
**/
public interface SSP_ITriggerHandler 
{
    void BeforeInsert(List<SObject> newItems);
 
    void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
 
    void BeforeDelete(Map<Id, SObject> oldItems);
 
    void AfterInsert(Map<Id, SObject> newItems);
 
    void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
 
    void AfterDelete(Map<Id, SObject> oldItems);
 
    void AfterUndelete(Map<Id, SObject> oldItems);
 
    Boolean IsDisabled();
}