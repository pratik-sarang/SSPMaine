/*
* classname     :  SSP_MedicareCoverageSummaryQueueRule
* @description  :  Class for identifying whether to queue MEdicare Coverage screen for particular individual
* @author       :  Varun Kochar 
* @date         :  17/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_MedicareCoverageSummaryQueueRule extends BasicNavFlowRule {
    
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
            if(ctxData!=null && ctxData.MemberId != '' && ctxData.MemberId != null && ctxData.ApplicationId != '' && ctxData.ApplicationId != null && ctxData.queueObject != null){
                   SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ? 
                       									ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ? ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                   result = appIndividualRecord != null && appIndividualRecord.SSP_Member__r.IsReceivingMedicareBenefitToggle__c == SSP_GlobalConstants.YES && (appIndividualRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.STATE) || appIndividualRecord.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID));                
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SSIBenefitQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
    
}