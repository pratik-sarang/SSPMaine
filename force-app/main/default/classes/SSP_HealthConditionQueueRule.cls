/*
* classname     :  SSP_HealthConditionQueueRule
* @description  :  Class for identifying whether to queue sspEntitledBenefits screen for particular individual
* @author       :  Naveena Malapati   
* @date         :  02/25/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_HealthConditionQueueRule extends BasicNavFlowRule {
    
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
    public override boolean isRequired(Context ctx, ContextData ctxData){
        Boolean result = false;
        try{
            if(ctxData!=null && ctxData.MemberId != '' && ctxData.MemberId != null && ctxData.ApplicationId != null && ctxData.queueObject != null){
                   
                SSP_ApplicationIndividual__c appIndividualRecord = 
                        					ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);                    						                    
                List<String> selectedProgramList = (appIndividualRecord != null && appIndividualRecord.ProgramsApplied__c != null) ? appIndividualRecord.ProgramsApplied__c.split(';') : new List<String>();
                
                result = appIndividualRecord != null && ((appIndividualRecord.SSP_Member__r.HasEmergencyMedicalConditionToggle__c == SSP_GlobalConstants.YES) &&
                    	 (appIndividualRecord.SSP_Member__r.IsUSCitizenToggle__c == SSP_GlobalConstants.NO) && selectedProgramList.contains(SSP_GlobalConstants.MEDICAID)) ||
                    	 (appIndividualRecord.SSP_Member__r.IsRecoveryFromIllnessOrInjuryToggle__c == SSP_GlobalConstants.YES) &&
                          (selectedProgramList.contains(SSP_GlobalConstants.SNAP) || selectedProgramList.contains(SSP_GlobalConstants.KTAP));    
                
        }
        }
        catch(Exception ex){   
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthConditionQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
}
}