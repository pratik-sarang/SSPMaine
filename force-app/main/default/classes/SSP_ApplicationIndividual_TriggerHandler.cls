/*
* classname     : SSP_ApplicationIndividual_TriggerHandler
* @description  : This class is a Handler class for SSP_ApplicationIndividual_Trigger.
* @author       : Karthik Gulla
* @date         : 04/24/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Karthik Gulla        04/24/2020      Initial Version
*/
public with sharing class SSP_ApplicationIndividual_TriggerHandler implements SSP_ITriggerHandler {
    
    public void beforeInsert(List<SObject> newItems) {}
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try {
              for(Id individualId: oldItems.keySet()) {
                SSP_ApplicationIndividual__c oldIndividual = (SSP_ApplicationIndividual__c)oldItems.get(individualId);
                SSP_ApplicationIndividual__c newIndividual = (SSP_ApplicationIndividual__c)newItems.get(individualId);
               
                if(newIndividual!= null && newIndividual.ProgramsApplied__c!= null && !newIndividual.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID) ){
                    newIndividual.MedicaidType__c =null;
                }
              }
            }
        catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_ApplicationIndividual_TriggerHandler', 'beforeUpdate', ex.getMessage() , true);
        }
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    /**
	* method 		: AfterInsert
	* @description 	: Method executes to set MAGI/Non-MAGI application, when new applicationIndividual records are created
	* @author 		: Karthik Gulla
	* @param 		: List<SObject> newItems - Contains new ApplicationIndividual data
	* @return		: void
	* */
    public void afterInsert(Map<Id, SObject> newItems) {
        try {
            Set<String> setMemberIds = new Set<String>();
            String sApplicationId = '';
            for(SSP_ApplicationIndividual__c sspAppIndivRecord : (List<SSP_ApplicationIndividual__c>)newItems.values()){
                if(sspAppIndivRecord.MemberStatus__c != SSP_GlobalConstants.MEMBER_REMOVE_STATUS
                && sspAppIndivRecord.SSP_Member__c != null) {
                    setMemberIds.add(sspAppIndivRecord.SSP_Member__c);
                }
            }
            if(!setMemberIds.isEmpty()){
                SSP_MemberService.checkMembersAgeBlindDisabledInfo(sApplicationId, setMemberIds);
            }
        } catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_ApplicationIndividual_TriggerHandler', 'AfterInsert', ex.getMessage() , true);
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

     public Boolean isDisabled() {
        return false;
    }
}