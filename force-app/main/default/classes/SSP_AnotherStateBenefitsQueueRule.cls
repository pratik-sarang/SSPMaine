/*
* classname     :  SSP_AnotherStateBenefitsQueueRule
* @description  :  Class for identifying whether to queue sspOutOfStateBenefit screen for particular individual
* @author       :  Sai Kiran   
* @date         :  02/08/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_AnotherStateBenefitsQueueRule extends BasicNavFlowRule {
    
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
            if(ctxData!=null && ctxData.MemberId != '' && ctxData.MemberId != null && ctxData.queueObject != null){
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap != null ? 
                    			  				ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ? 
                    							ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) : new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                if(appIndividualRecord != NULL && appIndividualRecord.ProgramsApplied__c != NULL){
                    Boolean programCheck = SSP_Utility.checkApplicablePrograms(appIndividualRecord.ProgramsApplied__c.split(';'), SSP_GlobalConstants.BENEFITS_STATE_PROGRAMS);
                    if(appIndividualRecord != null && appIndividualRecord.SSP_Member__r.HasReceivedBenefitsFromOtherStateToggle__c == SSP_GlobalConstants.YES
                       && programCheck){
                           result = true;
                       }
                    
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SSIBenefitQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
    
}