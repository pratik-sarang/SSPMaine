/*
* classname     :  SSP_EntitledBenefitsQueueRule
* @description  :  Class for identifying whether to queue sspEntitledBenefits screen for particular individual
* @author       :  Shrikant Raut   
* @date         :  12/19/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_EntitledBenefitsQueueRule extends BasicNavFlowRule {
    
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
        Set<String> lstEntitledBenefitsPrograms = new Set<String>();
        lstEntitledBenefitsPrograms.add(SSP_GlobalConstants.KTAP);
        lstEntitledBenefitsPrograms.add(SSP_GlobalConstants.MEDICAID);
        try{
            if(ctxData!=null && String.isNotBlank(ctxData.MemberId) && ctxData.queueObject != null){ //Iron Dome Fix
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                if(appIndividualRecord != NULL && appIndividualRecord.ProgramsApplied__c != NULL){
                    List<String> selectedProgramList = appIndividualRecord.ProgramsApplied__c.split(';');
                    Set<String> evaluatingSet = lstEntitledBenefitsPrograms;
                    Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                    result = (appIndividualRecord.SSP_Member__r.ReceivesEntitledIncomeToggle__c == SSP_GlobalConstants.YES) && 
                        programCheck;
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_EntitledBenefitsQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}