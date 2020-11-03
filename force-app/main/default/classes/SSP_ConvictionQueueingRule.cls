/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_ConvictionQueueingRule
*   Create By   :   Samridh Manucha
*   Create Date :   JAN-21-2020
*   Description :   This class checks conviction Screen needs to be queued.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                    Description
*   --------------------------------------------------------------------------------------
*    Samridh Manucha           JAN-21-2020             Initial Version
*
*****************************************************************************************************************************/
public with sharing class SSP_ConvictionQueueingRule extends BasicNavFlowRule {
    
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
        Boolean hasConvictedCrime = false;
        try {            
            if(ctxData.ApplicationId != null && ctxData.MemberId != null && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                List<String> selectedProgramList = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>();
                Set<String> evaluatingSet = SSP_GlobalConstants.CONVICTION_PROGRAMS;
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                hasConvictedCrime = appIndividualRecord != null && appIndividualRecord.SSP_Application__r.HasConvictedCrimeToggle__c == SSP_GlobalConstants.YES &&
                         appIndividualRecord.IsHeadOfHousehold__c == true && programCheck;                         
            }            
            /*Boolean selectedProgram;
            List<SSP_ApplicationIndividual__c> applicationIndividual = //SSP_ApplicationIndividualSelector.queryApplicationIndividualMemberData(memberId, fields);
                SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','MemberStatus__c' => '!='}, 
                                                                                 new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c', 'IsHeadOfHousehold__c', 'SSP_Application__r.HasConvictedCrimeToggle__c'}, 
                                                                                 new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId),'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId),'MemberStatus__c'=> 'Removed'});
            if(!applicationIndividual.isEmpty()){
                String programs = applicationIndividual[0].ProgramsApplied__c;
                List<String> programValues = programs.split(';');
                for(String program : programValues){
                    if(SSP_GlobalConstants.CONVICTION_PROGRAMS.contains(program)){
                        selectedProgram = true;
                        break;                     
                    }
                }
                hasConvictedCrime = (applicationIndividual[0].SSP_Application__r.HasConvictedCrimeToggle__c == SSP_GlobalConstants.YES && applicationIndividual[0].IsHeadOfHousehold__c == true && selectedProgram) ? true : false ;
            }*/
            
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_ConvictionQueueingRule', 'isRequired', e.getMessage() , true);
        }
        return hasConvictedCrime;
    }
}