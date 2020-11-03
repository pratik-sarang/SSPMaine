/*
* classname     : SSP_MemberHandler
* @description  : This class is a Handler class for SSP_MemberTrigger.
* @author       : Ashwin Kasture
* @date         : 03/05/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture        03/05/2020      Initial Version
*/
public with sharing class SSP_MemberHandler implements SSP_ITriggerHandler {
    
    public void BeforeInsert(List<SObject> newItems) {}
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void BeforeDelete(Map<Id, SObject> oldItems) {}

    /**
	* method 		: AfterInsert
	* @description 	: Method executes to set MAGI/Non-MAGI application, when new Members are inserted
	* @author 		: Ashwin Kasture
	* @param 		: List<SObject> newItems - Contains new Member data
	* @return		: void
	* */
    public void AfterInsert(Map<Id, SObject> newItems) {
        /*try {
        	SSP_MemberService.checkMembersAgeBlindDisabledInfo(newItems.values());
        } catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberHandler', 'AfterInsert', ex.getMessage() , true);
        }*/
    }

    /**
	* method 		: AfterUpdate
	* @description 	: Method executes to set MAGI/Non-MAGI application, when existing Members are updated
	* @author 		: Ashwin Kasture
	* @param 		: List<SObject> newItems - Contains updated Member data
	* @param		: Map<Id, SObject> oldItems - Contains old Member data.
	* @return		: void
	* */
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        try {
            Set<String> setMemberIds = new Set<String>();
            Set<Id> setEducationMemberIds = new Set<Id>();
            String sApplicationId = '';
            for(SSP_Member__c sspMember : (List<SSP_Member__c>)newItems.values()){
                if(((SSP_Member__c)oldItems.get(sspMember.Id)).IsBlindToggle__c != sspMember.IsBlindToggle__c
                || ((SSP_Member__c)oldItems.get(sspMember.Id)).IsDisabledToggle__c != sspMember.IsDisabledToggle__c){
                    setMemberIds.add(sspMember.Id);
                }

                if(((SSP_Member__c)oldItems.get(sspMember.Id)).IsCurrentlyEnrolledInSchoolToggle__c == SSP_GlobalConstants.YES
                    && sspMember.IsCurrentlyEnrolledInSchoolToggle__c == SSP_GlobalConstants.NO){
                    setEducationMemberIds.add(sspMember.Id);
                }
            }
            if(!setMemberIds.isEmpty()){
                SSP_MemberService.checkMembersAgeBlindDisabledInfo(sApplicationId, setMemberIds);
            }

            if(!setEducationMemberIds.isEmpty()){
                SSP_EducationController.updateDeleteOnCurrentEducationDetailsForMembers(setEducationMemberIds);
            }
        } catch(Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, 'SSP_MemberHandler', 'AfterUpdate', ex.getMessage() , true);
        }
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {}

    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    public Boolean IsDisabled() {
        return false;
    }
}