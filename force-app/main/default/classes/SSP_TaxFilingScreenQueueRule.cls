/*
* classname     :  SSP_TaxFilingScreenQueueRule
* @description  :  Class for identifying whether to queue sspTaxFilingDetails screen for particular individual
* @author       :  Karthik Gulla  
* @date         :  03/10/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
**/
public with sharing class SSP_TaxFilingScreenQueueRule extends BasicNavFlowRule {
    
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
        List<String> lstTaxFilingPrograms = new List<String>();
        lstTaxFilingPrograms.add(SSP_GlobalConstants.MEDICAID);
        lstTaxFilingPrograms.add(SSP_GlobalConstants.STATE);
        try{
            if(ctxData!=null 
                && ctxData.MemberId != '' && ctxData.MemberId != null
                && ctxData.ApplicationId != '' && ctxData.ApplicationId != null && ctxData.queueObject != null){
                    
                    SSP_ApplicationIndividual__c appIndividualRecord = ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId) != null ? 
                        					ctxData.queueObject.memberAppIndividualMap.containskey(ctxData.MemberId) ? 
                        					ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId): 
                    						new SSP_ApplicationIndividual__c() : new SSP_ApplicationIndividual__c();
                        //ctxData.queueObject.memberAppIndividualMap.get(ctxData.MemberId);
                    List<String> lstMemberPrograms = appIndividualRecord.ProgramsApplied__c != null ? appIndividualRecord.ProgramsApplied__c.split(';') :
                    								 new List<String>();                
                if(SSP_ResourcesService.hasProgramApplicable(lstMemberPrograms, lstTaxFilingPrograms)){
                    result = true;
                }
            }
        }
        catch(Exception ex){            
            LOG_LogMessageUtility.logMessage(ex, 'SSP_TaxFilingScreenQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
}