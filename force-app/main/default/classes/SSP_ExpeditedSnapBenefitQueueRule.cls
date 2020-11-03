/*
* classname     :  SSP_ExpeditedSnapBenefitQueueRule
* @description  :  Class for identifying whether to queue ExpeditedSnapBenefit screen for particular individual
* @author       :  Sai Kiran   
* @date         :  02/07/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_ExpeditedSnapBenefitQueueRule extends BasicNavFlowRule{
    
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
            if(ctxData!=null && ctxData.ApplicationId != '' && ctxData.ApplicationId != null){
                for(SSP_Application__c objApplication :
                    SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                 new Set<String>{'Id',  'ProgramsApplied__c', 'IsApplicationSubmittedEarly__c'}, 
                                                                 new Map<String, String>{'limit'=>'1','Id'=> ctxData.ApplicationId})){
                                                                     if(objApplication.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP) &&
                                                                        objApplication.IsApplicationSubmittedEarly__c == 'Y'){
                                                                         result = true;
                                                                     }
                                                                 }
                
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ExpeditedSnapBenefitQueueRule', 'isRequired', ex.getMessage() , true);
        }
        return result;
    }
    
}