/*
* classname     :  SSP_HealthcareScreenQueueRule
* @description  :  Class for identifying whether to queue sspHealthcare screen for an Application
* @author       :  Varun Kochar   
* @date         :  18/12/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_HealthcareScreenQueueRule extends BasicNavFlowRule {
    
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
            
            if(ctxData != null && String.isNotBlank(ctxData.ApplicationId) && ctxData.queueObject != null) {
                /*List<SSP_Application__c> lstApplication = new List<SSP_Application__c>();
                lstApplication = SSP_ApplicationSelector.queryApplicationData (
                    new Map<String, String> {'objectName' => 'SSP_Application__c'}, 
                    new Set<String> {'Id', 'NotEnrolledInHealthCareCoverageToggle__c'},
                    new Map<String, String> {'limit'=>'1', 'Id'=> ctxData.ApplicationId}
                );*/
                List<SSP_ApplicationIndividual__c> appIndividualList = ctxData.queueObject.applicationIndividualList;
                if(!appIndividualList.isEmpty() && appIndividualList[0] != null && appIndividualList[0].SSP_Application__r.NotEnrolledInHealthCareCoverageToggle__c == SSP_GlobalConstants.YES) {
                    result = true;
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HealthcareScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}