/*
* classname     :  SSP_KHIPPPreferredPaymentMethodQueueRule
* @description  :  Class for identifying whether to queue KIHIPP Preferred Payment Method screen for particular individual
* @author       :  Varun Kochar 
* @date         :  17/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_KHIPPPreferredPaymentMethodQueueRule extends BasicNavFlowRule {
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
        Boolean isNoSelected = false;
        try {
            if(ctxData!= null && String.isNotBlank(ctxData.ApplicationId) && ctxData.queueObject != null) {
                Set<String> memberIdSet = new Set<String>();
                List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
                List<SSP_InsuranceCoveredIndiv__c> lstInsuranceCoveredIndiv = new List<SSP_InsuranceCoveredIndiv__c>();
                
                lstApplicationIndividual = ctxData.queueObject.applicationIndividualList;
                /*SSP_ApplicationIndividualSelector.queryApplicationIndividualData ( 
                    new Map<String, String> {'objectName'=>'SSP_ApplicationIndividual__c', 'operator'=>'AND'}, 
                    new Set<String> {'Id',  'SSP_Member__c','ProgramsApplied__c','SSP_Application__r.EnrolledInHealthCareCoverageToggle__c','SSP_Application__r.NotEnrolledInHealthCareCoverageToggle__c'}, 
                    new Map<String, String> {'SSP_Application__c'=> String.escapeSingleQuotes(ctxData.ApplicationId)}
                );*/
                if(!lstApplicationIndividual.isEmpty()){
                for(SSP_ApplicationIndividual__c appIndiv : lstApplicationIndividual) {
                    if(String.isNotBlank(appIndiv.ProgramsApplied__c) && appIndiv.ProgramsApplied__c != null && appIndiv.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP)){
                        memberIdSet.add(appIndiv.SSP_Member__c);
                        }
                    }
                }
                if(!lstApplicationIndividual.isEmpty() && lstApplicationIndividual[0] != null && lstApplicationIndividual[0].SSP_Application__r.EnrolledInHealthCareCoverageToggle__c == 'N' && lstApplicationIndividual[0].SSP_Application__r.NotEnrolledInHealthCareCoverageToggle__c == 'N') {                
                    isNoSelected = true;
                }
				if(!memberIdSet.isEmpty()){
                    // Start - CD1 Security Fixes
                    lstInsuranceCoveredIndiv = SSP_SharingBypassFetcher.fetchRecords (
                    	new Map<String, String>{'objectName'=>'SSP_InsuranceCoveredIndiv__c', 'IN'=>'SSP_Member__c', 'operator'=>'AND'}, 
                    	new Set<String>{'Id'}, 
                    	new Map<String, String>{'limit' => '1','SSP_InsurancePolicy__r.IsKIHIPPSourceOfCoverage__c' => '#true#', 'IsPolicyHolder__c'=> '#true#','IsEnrolled__c' => '#true#', 'SSP_Member__c'=> String.join(new List<String>(memberIdSet), ',')}
                	);
                    // End - CD1 Security Fixes
                }                
                if(lstInsuranceCoveredIndiv.size() > 0 && !isNoSelected) {                    
            	    result = true;
                }
            }
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_KHIPPPreferredPaymentMethodQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}