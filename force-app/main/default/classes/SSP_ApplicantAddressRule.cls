/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_ApplicantAddressRule
*   Create By   :   Ajay Saini
*   Create Date :   NOV-15-2019
*   Description :   This class is checks id Address screen is required or not.
*   Modification Log:
*   * ------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
* 
*****************************************************************************************************************************/
public with sharing class SSP_ApplicantAddressRule extends BasicNavFlowRule {
	/**
     * Invoked on workflow "next" action. If true is returned then the page will be marked as "required" in the
     * current flow and so it will be queued to be loaded on its turn. If false is returned then the page
     * will be marked as "not required" and hence will not be loaded in the flow.
     *
     * @param ctx Context object
     * @param ctxData ContextData object
     *
     * @return boolean
     */
    public override boolean isRequired(Context ctx, ContextData ctxData) {
        Boolean required = false;
        try {
            if(ctxData.queueObject != null){
                List<SSP_ApplicationIndividual__c> applicationIndividualList = ctxData.queueObject.applicationIndividualList != null ?
                    		ctxData.queueObject.applicationIndividualList :  new List<SSP_ApplicationIndividual__c> ();
                SSP_ApplicationIndividual__c headOfHousehold, currentIndividual;
                currentIndividual = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                for(SSP_ApplicationIndividual__c appIndiv : applicationIndividualList){
                    if(appIndiv.IsHeadOfHousehold__c){
                        headOfHousehold = appIndiv;
                        break;
                    }
                }                
                List<String> lstPrograms = !applicationIndividualList.isEmpty() ? applicationIndividualList[0] != null ?
                    						applicationIndividualList[0].ProgramsApplied__c != null ?
                    						applicationIndividualList[0].ProgramsApplied__c.split(';') : new List<String>() :
                							new List<String>() : new List<String>();
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(lstPrograms, SSP_GlobalConstants.ADDRESS_PROGRAMS);
                required = programCheck && (currentIndividual != null && headOfHousehold != null) && (currentIndividual.Id == headOfHousehold.Id) ||
                       (headOfHousehold.SSP_Member__r.SameAddressInfoAsHOHToggle__c  != SSP_GlobalConstants.YES) ||
                       (ctxData.modeValue == SSP_GlobalConstants.RAC_AddMember && currentIndividual.MemberStatus__c == SSP_GlobalConstants.MEMBER_STATUS_New);
                
            }
            /*Map<String, String> detailMap = new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator' => 'AND'};
            Set<String> fieldSet = new Set<String>{'Id', 'IsHeadOfHousehold__c', 'SSP_Member__r.SameAddressInfoAsHOHToggle__c', 'SSP_Application__c', 'MemberStatus__c'};
            List<SSP_ApplicationIndividual__c> headOfHousehold = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(detailMap, fieldSet,
                new Map<String, String>{'limit' =>'10', 'SSP_Application__c' => String.escapeSingleQuotes(ctxData.applicationId),  'IsHeadOfHousehold__c'=> '#true#'});
            List<SSP_ApplicationIndividual__c> currentIndividual = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(detailMap, fieldSet,
                new Map<String, String>{'limit' =>'10', 'SSP_Application__c' => String.escapeSingleQuotes(ctxData.applicationId),  'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.memberId)});
            required = currentIndividual.isEmpty() 
            || headOfHousehold.isEmpty() 
            || currentIndividual.get(0).Id == headOfHousehold.get(0).Id
            || headOfHousehold.get(0).SSP_Member__r.SameAddressInfoAsHOHToggle__c != SSP_GlobalConstants.YES
            || ctxData.modeValue == 'addRemoveMember' && currentIndividual.get(0).MemberStatus__c == 'New';*/
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_ApplicantAddressRule', 'isRequired', e.getMessage() , true);
        }
        return required;
    }
}