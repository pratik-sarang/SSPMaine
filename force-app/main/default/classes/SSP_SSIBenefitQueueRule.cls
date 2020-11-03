/*
* classname     :  SSP_SSIBenefitQueueRule
* @description  :  Class for identifying whether to queue sspSSIBenefits screen for particular individual
* @author       :  Sai Kiran   
* @date         :  01/13/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_SSIBenefitQueueRule extends BasicNavFlowRule {
    
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
                SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                if(appIndividualRecord != NULL && appIndividualRecord.ProgramsApplied__c != NULL){
                    List<String> selectedProgramList = appIndividualRecord.ProgramsApplied__c.split(';');
                    Set<String> evaluatingSet = SSP_GlobalConstants.SSI_BENEFITS_PROGRAMS;
                    Boolean programCheck = SSP_Utility.checkApplicablePrograms(selectedProgramList, evaluatingSet);
                    result = (appIndividualRecord.SSP_Member__r.ReceivesSSIBenefitsToggle__c == SSP_GlobalConstants.YES) && 
                        programCheck;
                    
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SSIBenefitQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}