/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_EducationSummaryQueueingRule
*   Create By   :   Ajay Saini
*   Create Date :   DEC-18-2019
*   Description :   This class checks if education summary needs to be queued.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                Description
*   --------------------------------------------------------------------------------------
*    Ajay Saini             DEC-18-2019             Initial Version
*
*****************************************************************************************************************************/
public with sharing class SSP_EducationSummaryQueueingRule extends BasicNavFlowRule {
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
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList;
            if(String.isNotBlank(ctxData.MemberId) && String.isNotBlank(ctxData.ApplicationId) && ctxData.queueObject != null){
                //required = member.IsCurrentlyEnrolledInSchoolToggle__c == SSP_GlobalConstants.YES;
                String memberId = String.escapeSingleQuotes(ctxData.MemberId);
                
                //update logic as part of defect 361239 : visverma
                SSP_ApplicationIndividual__c sspAppInd = ctxData.queueObject.memberAppIndividualMap != null ?
                    ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ? ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId)
                    : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                /*sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                     new Set<String>{'Id', 'SSP_Application__c', 'SSP_Member__c', 'ProgramsApplied__c', 'SSP_Member__r.AGE__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId), 
                                                                                         'SSP_Member__c'=> String.escapeSingleQuotes(ctxData.MemberId)});*/
            
            //if (!sspApplicationIndividualList.isEmpty()){
                //SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                Boolean selectedProgram = false;
                String programs = sspAppInd.ProgramsApplied__c != null ? sspAppInd.ProgramsApplied__c : '';
                List<String> programValues = programs != null && String.isNotBlank(programs) ? programs.split(';') : new list<String>();
                Integer age = sspAppInd.SSP_Member__c != null ? Integer.valueOf(sspAppInd.SSP_Member__r.AGE__c) : 0;
                
                 for(String program : programValues){
                    if(SSP_GlobalConstants.EDUCATION_SUMMARY_PROGRAMS_WITHOUT_AGE_CHECK.contains(program)){
                        required = true;
                        
                        break;                     
                    }
                    else if( SSP_GlobalConstants.EDUCATION_SUMMARY_PROGRAMS_WITH_AGE_CHECK_MA.contains(program) && age>=SSP_GlobalConstants.EDUCATION_SUMMARY_MA_AGE_MIN){
                         required = true;
                        break;
                    }
                    else if(SSP_GlobalConstants.EDUCATION_SUMMARY_PROGRAMS_WITH_AGE_CHECK_SN.contains(program) && age>=SSP_GlobalConstants.EDUCATION_SUMMARY_SN_AGE_MIN && age<SSP_GlobalConstants.EDUCATION_SUMMARY_SN_AGE_MAX){
                         required = true;
                        break;
                    }
                    
                }
                
            }
        }
        catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_EducationSummaryQueueingRule', 'isRequired', e.getMessage() , true);
        }
        return required;
    }
}