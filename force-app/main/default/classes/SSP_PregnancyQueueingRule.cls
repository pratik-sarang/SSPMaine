/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_PregnancyQueueingRule
*   Create By   :   Shivam Tiwari
*   Create Date :   DEC-19-2019
*   Description :   This class checks if Pregnancy Screen needs to be queued.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                	Description
*   --------------------------------------------------------------------------------------
*    Shivam Tiwari             DEC-19-2019             Initial Version
*
*****************************************************************************************************************************/
public with sharing class SSP_PregnancyQueueingRule extends BasicNavFlowRule {
    
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
        Boolean result = false;
        try {
            List<String> fields = new List<String>{'IsPregnantInLastThreeMonthsToggle__c', 'GenderCode__c', 'Age__c'};
                Id memberId = ctxData.memberId;
            Id applicationId = ctxData.applicationId;
            if(ctxData.queueObject != null && ctxData.MemberId != null && ctxData.ApplicationId != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ? ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ?
                												   ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c ();                    
                List<String> selectedProgramList = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c != null ?
                    							   appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>() : new List<String>();
                Set<String> evaluatingSet = SSP_GlobalConstants.PREGNANCY_ASSISTANCE_PROGRAMS;
                Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                result = appIndividualRecord != null && 
                        ((appIndividualRecord.SSP_Member__r.IsPregnantInLastThreeMonthsToggle__c == SSP_GlobalConstants.YES) 
                         && (appIndividualRecord.SSP_Member__r.GenderCode__c == SSP_GlobalConstants.FEMALE) && programCheck);                         
            }
            /*List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = 
                SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                 new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c', 'ProgramsApplied__c', 'MedicaidType__c'}, 
                                                                                 new Map<String, String>{'limit'=>'10','SSP_Application__c'=> String.escapeSingleQuotes(applicationId),'SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
            
            SSP_Member__c sspMemberList = SSP_MemberSelector.queryMemberDataById(memberId, fields);
            if (sspMemberList!=null && !sspApplicationIndividualList.isEmpty()){
                SSP_ApplicationIndividual__c sspAppInd = sspApplicationIndividualList.get(0);
                Boolean selectedProgram = false;
                String programs = sspAppInd.ProgramsApplied__c;
                List<String> programValues = programs.split(';');
                for(String program : programValues){
                    if(SSP_GlobalConstants.PREGNANCY_ASSISTANCE_PROGRAMS.contains(program)){
                        selectedProgram = true;
                        break;                     
                    }
                }
                if(sspMemberList.IsPregnantInLastThreeMonthsToggle__c == SSP_GlobalConstants.YES && sspMemberList.GenderCode__c == SSP_GlobalConstants.FEMALE && selectedProgram){
                    result = true;
                }
            }*/
            
            
        } catch (Exception e) {
            LOG_LogMessageUtility.logMessage(e, 'SSP_PregnancyQueueingRule', 'isRequired', e.getMessage() , true);
        }
        return result;
    }
    
}