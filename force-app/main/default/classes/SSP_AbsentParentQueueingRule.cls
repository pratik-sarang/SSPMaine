/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_AbsentParentQueueingRule
*   Create By   :   Ajay Saini
*   Create Date :   DEC-20-2019
*   Description :   This class checks if absent parent summary screen needs to be queued or not.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini             DEC-20-2019             Initial Version
*
*****************************************************************************************************************************/
public with sharing class SSP_AbsentParentQueueingRule extends BasicNavFlowRule {
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
            if(String.isBlank(ctxData.MemberId) || String.isBlank(ctxData.ApplicationId)) {
                return required;
            }
            Set<String> individalFields = new Set<String>{'SSP_Member__r.Age__c', 'SSP_Application__r.ProgramsApplied__c', 'IsHeadOfHousehold__c'};
            Id memberId = ctxData.memberId;
            Id applicationId = ctxData.applicationId;
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = new List<SSP_ApplicationIndividual__c>();
            if(ctxData.queueObject != null && ctxData.queueObject.applicationIndividualList != null) {
                sspApplicationIndividualList = ctxData.queueObject.applicationIndividualList;
            }
            else  {
                sspApplicationIndividualList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, individalFields, null);
            }
            Map<Id, SSP_ApplicationIndividual__c> individalMap = new Map<Id, SSP_ApplicationIndividual__c>();
            for(SSP_ApplicationIndividual__c individal: sspApplicationIndividualList) {
                individalMap.put(individal.SSP_Member__c, individal);
            }
            //Added By Sai
            Set<ID> lstMemberIds = new Set<ID>();
            List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualMemberData(applicationId, new Set<String>{'SSP_Member__c', 'SSP_Application__c'});
            if(applicationIndividuals != null) {
                for(SSP_ApplicationIndividual__c individual: applicationIndividuals) {
                    if(memberId != individual.SSP_Member__c) {
                        lstMemberIds.add(individual.SSP_Member__c);
                    }
                }
            }
            //End
            Set<String> fields = new Set<String>{'Name', 'SSP_Member__c'};
            String relationTypes = SSP_GlobalConstants.fathersCodeList + ',' + SSP_GlobalConstants.mothersCodeList;
            Map<String, String> detailMap = new Map<String, String>{'objectName' => 'SSP_Relationship__c', 'operator' => 'AND', 'IN' => 'RelationshipType__c,SSP_Member__c'};
            Map<String, String> conditionsMap = new Map<String, String>{'RelationshipType__c' => relationTypes, 'SSP_MemberRelatedTo__c' => memberId,'SSP_Member__c' =>String.join(new List<Id>(lstMemberIds), ',')};
            List<SSP_Relationship__c> parentsList = SSP_RelationshipSelector.queryRelationshipData(detailMap, fields, conditionsMap);
            Integer parentCount = 0;
            if(parentsList != null) {
                for(SSP_Relationship__c relationship: parentsList) {
                    if(individalMap.containsKey(relationship.SSP_Member__c)) {
                        parentCount++;
                    }
                }
            }
            SSP_ApplicationIndividual__c individal = individalMap.get(memberId);
            required = (individal.SSP_Application__r.ProgramsApplied__c == null) ||
                (individal.SSP_Application__r.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID) || individal.SSP_Application__r.ProgramsApplied__c.contains(SSP_GlobalConstants.KTAP)) &&
                (individal.SSP_Member__r.Age__c <= 18) &&
                !individal.IsHeadOfHousehold__c &&
                parentCount < 2;
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_AbsentParentQueueingRule', 'isRequired', e.getMessage() , true);
        }
        return required;
    }
}