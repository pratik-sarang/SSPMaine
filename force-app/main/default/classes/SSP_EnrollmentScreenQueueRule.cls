/*
* classname     :  SSP_EnrollmentScreenQueueRule
* @description  :  Class for identifying whether to queue sspEnrollment screen for an Application
* @author       :  Varun Kochar   
* @date         :  18/12/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_EnrollmentScreenQueueRule extends BasicNavFlowRule {
    
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
            
            if(ctxData != null && ctxData.ApplicationId != null && ctxData.queueObject  != null) {
                List<SSP_ApplicationIndividual__c> appIndividualList = ctxData.queueObject.applicationIndividualList;
                
                if( !appIndividualList.isEmpty() && appIndividualList[0] != null && appIndividualList[0].SSP_Application__r.EnrolledInHealthCareCoverageToggle__c == SSP_GlobalConstants.YES) {
                    result = true;                                                                     
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_EnrollmentScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}