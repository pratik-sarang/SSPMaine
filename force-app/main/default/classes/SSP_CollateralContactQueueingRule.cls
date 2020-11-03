/***************************************************************************************************************************
*   Type        :   Queueing Rule
*   Name        :   SSP_CollateralContactQueueingRule
*   Create By   :   Rahul Kumar
*   Create Date :   July-06-2020
*   Description :   This class checks if collateral Screen needs to be queued.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                    Description
*   --------------------------------------------------------------------------------------
*    Rahul Kumar             July-06-2020             Initial Version
*
*****************************************************************************************************************************/

public with sharing class SSP_CollateralContactQueueingRule extends BasicNavFlowRule {
    
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
            if(ctxData!=null && ctxData.ApplicationId != '' && ctxData.ApplicationId != null && ctxData.queueObject != null){
                
                List<SSP_ApplicationIndividual__c> appIndividualList = ctxData.queueObject.applicationIndividualList;
                if(!appIndividualList.isEmpty()){
                    SSP_ApplicationIndividual__c appIndividualRecord = appIndividualList[0];
                    List<String> programList = appIndividualRecord != null ? appIndividualRecord.ProgramsApplied__c != null ? appIndividualRecord.ProgramsApplied__c.split(';') :
                                               new List<String>() : new List<String>();
                    if( !programList.isEmpty() && programList.contains(SSP_GlobalConstants.SNAP)){
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